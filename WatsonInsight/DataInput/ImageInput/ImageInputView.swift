//
//  ImageInputView.swift
//  WatsonInsight
//
//  Created by Oleg Ivanov on 13.09.16.
//  Copyright © 2016 IBM. All rights reserved.
//

import UIKit
import Photos

class ImageInputView: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITableViewDataSource, UITableViewDelegate {

	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var activityIndicator: WatsonActivityView!
	@IBOutlet weak var activityBackground: UIView!
	@IBOutlet weak var tableView: UITableView!

	var visualRecognitionModel = VisualRecognitionModel()

    override func viewDidLoad() {
        super.viewDidLoad()

		tableView.delegate = self
		tableView.dataSource = self
		tableView.tableFooterView = UIView(frame: CGRect.zero)
    }

	// MARK: Image picker

	@IBAction func cameraButtonDidPress(sender: UIBarButtonItem) {
		guard AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo) == .Authorized else {
			AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo) { granted in
				if granted {
					self.showCameraController(.Camera)
				} else {
					AlertUtil.displayAlert(self, title: "No camera available", message: "Please authorize access to the camera")
				}
			}
			return
		}

		self.showCameraController(.Camera)
	}

	@IBAction func galleryButtonDidPress(sender: UIBarButtonItem) {
		guard PHPhotoLibrary.authorizationStatus() == .Authorized else {
			PHPhotoLibrary.requestAuthorization {status in
				if status == .Authorized {
					self.showCameraController(.PhotoLibrary)
				} else {
					AlertUtil.displayAlert(self, title: "No gallery available", message: "Please authorize access to the photo gallery")
				}
			}
			return
		}

		self.showCameraController(.PhotoLibrary)
	}

	func showCameraController(sourceType: UIImagePickerControllerSourceType) {
		if !Reachability.isReachable() {
			AlertUtil.displayAlert(self, title: "No internet connection", message: "Internet connection is required to reach Watson")
			return
		}

		let picker = UIImagePickerController()
		picker.sourceType = sourceType
		picker.delegate = self

		self.presentViewController(picker, animated: true, completion: nil)
	}

	func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
		guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
		imageView.contentMode = .ScaleAspectFit
		imageView.image = image
		saveImageToFile(image)

		activityBackground.hidden = false
		activityIndicator.startAnimating()
		navigationItem.hidesBackButton = true

		visualRecognitionModel.analyze(imageFileURL(), modelDidChange: {
			self.tableView.reloadData()
		}) {
			self.activityBackground.hidden = true
			self.activityIndicator.stopAnimating()
			self.navigationItem.hidesBackButton = false
		}

		dismissViewControllerAnimated(true, completion: nil)
	}

	// MARK: Image file management

	func saveImageToFile(image: UIImage) {
		let applicationSupportDir = NSFileManager.defaultManager().URLsForDirectory(.ApplicationSupportDirectory, inDomains: .UserDomainMask).first!
		let fileManager = NSFileManager.defaultManager()
		if !fileManager.fileExistsAtPath(applicationSupportDir.path!) {
			do {
				try fileManager.createDirectoryAtURL(applicationSupportDir, withIntermediateDirectories: true, attributes: nil)
			}
			catch let err { print(err) }
		}

		let resizedImage = ImageUtil.resizeImage(image, targetSize: CGSize(width: 1024, height: 768))
		let jpegImage = UIImageJPEGRepresentation(resizedImage!, 0.8)
		jpegImage!.writeToFile(imageFileURL().path!, atomically: true)
	}

	func imageFileURL() -> NSURL {
		return NSFileManager.defaultManager().URLsForDirectory(.ApplicationSupportDirectory, inDomains: .UserDomainMask).first!.URLByAppendingPathComponent("image.jpg")!
	}

	// MARK: Table view lifecycle

	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return visualRecognitionModel.sections.count
	}

	func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		 return visualRecognitionModel.sections[section]
	}

	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		let sectionName = visualRecognitionModel.sections[section]

		switch sectionName {
		case "Faces":
			return visualRecognitionModel.faces!.count
		case "Text":
			return 1
		case "Classes":
			return visualRecognitionModel.classifications!.count
		default:
			return 0
		}
	}

	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let sectionName = visualRecognitionModel.sections[indexPath.section]

		switch sectionName {
		case "Faces":
			let cell = tableView.dequeueReusableCellWithIdentifier("faceCell") as! FaceCell
			let face = visualRecognitionModel.faces![indexPath.row]
			if let identity = face.identity {
				cell.genderLabel.text = identity.name
			} else {
				cell.genderLabel.text = face.gender.gender.lowercaseString
			}
			cell.ageLabel.text = "Age \(face.age.min)-\(face.age.max)"
			cell.faceImageView.image = visualRecognitionModel.facesPics[indexPath.row]
			return cell
		case "Text":
			let cell = tableView.dequeueReusableCellWithIdentifier("textCell") as! TextCell
			cell.textView.text = visualRecognitionModel.text
			return cell
		case "Classes":
			let cell = tableView.dequeueReusableCellWithIdentifier("classificationCell") as! ClassificationCell
			cell.classificationLabel.text = visualRecognitionModel.classifications![indexPath.row].classification
			if let hierarchy = visualRecognitionModel.classifications![indexPath.row].typeHierarchy {
				cell.classificationLabel.text?.appendContentsOf(" [" + hierarchy + "]")
			}
			cell.setScoreOpacity(visualRecognitionModel.classifications![indexPath.row].score)
			return cell
		default:
			return UITableViewCell()
		}
	}

	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		let sectionName = visualRecognitionModel.sections[indexPath.section]
		let cell: UITableViewCell

		switch sectionName {
		case "Faces":
			cell = tableView.dequeueReusableCellWithIdentifier("faceCell")!
		case "Text":
			cell = tableView.dequeueReusableCellWithIdentifier("textCell")!
		case "Classes":
			cell = tableView.dequeueReusableCellWithIdentifier("classificationCell")!
		default:
			return 0
		}

		return cell.bounds.size.height
	}

	func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
		let header = view as! UITableViewHeaderFooterView
		header.contentView.backgroundColor = UIColor(red: 120/255, green: 186/255, blue: 40/255, alpha: 1.0)
		header.textLabel!.textColor = UIColor.whiteColor()
	}

    // MARK: - Navigation

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		let composeInputView = segue.destinationViewController as! ComposeInputView

		composeInputView.inputText = visualRecognitionModel.text
	}

}

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

	@IBAction func cameraButtonDidPress(_ sender: UIBarButtonItem) {
		guard AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) == .authorized else {
			AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo) { granted in
				if granted {
					self.showCameraController(.camera)
				} else {
					AlertUtil.displayAlert(self, title: "No camera available", message: "Please authorize access to the camera")
				}
			}
			return
		}

		self.showCameraController(.camera)
	}

	@IBAction func galleryButtonDidPress(_ sender: UIBarButtonItem) {
		guard PHPhotoLibrary.authorizationStatus() == .authorized else {
			PHPhotoLibrary.requestAuthorization {status in
				if status == .authorized {
					self.showCameraController(.photoLibrary)
				} else {
					AlertUtil.displayAlert(self, title: "No gallery available", message: "Please authorize access to the photo gallery")
				}
			}
			return
		}

		self.showCameraController(.photoLibrary)
	}

	func showCameraController(_ sourceType: UIImagePickerControllerSourceType) {
		if !Reachability()!.isReachable {
			AlertUtil.displayAlert(self, title: "No internet connection", message: "Internet connection is required to reach Watson")
			return
		}

		let picker = UIImagePickerController()
		picker.sourceType = sourceType
		picker.delegate = self

		self.present(picker, animated: true, completion: nil)
	}

	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
		guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
		imageView.contentMode = .scaleAspectFit
		imageView.image = image
		saveImageToFile(image)

		activityBackground.isHidden = false
		activityIndicator.startAnimating()
		navigationItem.hidesBackButton = true

		visualRecognitionModel.analyze(imageFileURL(), modelDidChange: {
			DispatchQueue.main.async {
				self.tableView.reloadData()
			}
		}) {
			DispatchQueue.main.async {
				self.activityBackground.isHidden = true
				self.activityIndicator.stopAnimating()
				self.navigationItem.hidesBackButton = false
			}
		}

		dismiss(animated: true, completion: nil)
	}

	// MARK: Image file management

	func saveImageToFile(_ image: UIImage) {
		let applicationSupportDir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
		let fileManager = FileManager.default
		if !fileManager.fileExists(atPath: applicationSupportDir.path) {
			do {
				try fileManager.createDirectory(at: applicationSupportDir, withIntermediateDirectories: true, attributes: nil)
			}
			catch let err { print(err) }
		}

		let resizedImage = ImageUtil.resizeImage(image, targetSize: CGSize(width: 1024, height: 768))
		let jpegImage = UIImageJPEGRepresentation(resizedImage!, 0.8)
		try? jpegImage!.write(to: URL(fileURLWithPath: imageFileURL().path), options: [.atomic])
	}

	func imageFileURL() -> URL {
		return FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!.appendingPathComponent("image.jpg")
	}

	// MARK: Table view lifecycle

	func numberOfSections(in tableView: UITableView) -> Int {
		return visualRecognitionModel.sections.count
	}

	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		 return visualRecognitionModel.sections[section]
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		let sectionName = visualRecognitionModel.sections[section]

		switch sectionName {
		case "Faces":
			return visualRecognitionModel.faces!.count
		case "Classes":
			return visualRecognitionModel.classifications!.count
		default:
			return 0
		}
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let sectionName = visualRecognitionModel.sections[indexPath.section]

		switch sectionName {
		case "Faces":
			let cell = tableView.dequeueReusableCell(withIdentifier: "faceCell") as! FaceCell
			let face = visualRecognitionModel.faces![indexPath.row]
			if let identity = face.identity {
				cell.genderLabel.text = identity.name
			} else {
				cell.genderLabel.text = face.gender.gender.lowercased()
			}
            if let ageMin = face.age.min, let ageMax = face.age.max {
                cell.ageLabel.text = "Age \(ageMin)-\(ageMax)"
            } else if let ageMin = face.age.min {
                cell.ageLabel.text = "Age > \(ageMin)"
            } else if let ageMax = face.age.max {
                cell.ageLabel.text = "Age < \(ageMax)"
            }
			cell.faceImageView.image = visualRecognitionModel.facesPics[indexPath.row]
			return cell
		case "Classes":
			let cell = tableView.dequeueReusableCell(withIdentifier: "classificationCell") as! ClassificationCell
			cell.classificationLabel.text = visualRecognitionModel.classifications![indexPath.row].classification
			if let hierarchy = visualRecognitionModel.classifications![indexPath.row].typeHierarchy {
				cell.classificationLabel.text?.append(" [" + hierarchy + "]")
			}
			cell.setScoreOpacity(visualRecognitionModel.classifications![indexPath.row].score)
			return cell
		default:
			return UITableViewCell()
		}
	}

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		let sectionName = visualRecognitionModel.sections[indexPath.section]
		let cell: UITableViewCell

		switch sectionName {
		case "Faces":
			cell = tableView.dequeueReusableCell(withIdentifier: "faceCell")!
		case "Classes":
			cell = tableView.dequeueReusableCell(withIdentifier: "classificationCell")!
		default:
			return 0
		}

		return cell.bounds.size.height
	}

	func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
		let header = view as! UITableViewHeaderFooterView
		header.contentView.backgroundColor = UIColor(red: 120/255, green: 186/255, blue: 40/255, alpha: 1.0)
		header.textLabel!.textColor = UIColor.white
	}

}

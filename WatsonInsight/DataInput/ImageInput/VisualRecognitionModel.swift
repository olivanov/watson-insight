//
//  VisualRecognitionModel.swift
//  WatsonInsight
//
//  Created by Oleg Ivanov on 16.09.16.
//  Copyright © 2016 IBM. All rights reserved.
//

import Foundation
import VisualRecognitionV3

class VisualRecognitionModel {

	let visualRecognition = VisualRecognition(
		apiKey: BluemixAccess.credentials().visualRecognitionKey!,
		version: BluemixAccess.credentials().visualRecognitionVersion!)

	var classifications: [Classification]?
	var faces: [Face]?

	var facesPics = [UIImage]()
	var sections = [String]()

	private func resetResult() {
		classifications = nil
		faces = nil

		facesPics = [UIImage]()
		sections = [String]()
	}

	func analyze(_ imageFileURL: URL, modelDidChange: @escaping () -> Void, completion: @escaping () -> Void) {
		resetResult()
		modelDidChange()

		print("Start classifying...")
		self.visualRecognition.classify(imageFile: imageFileURL, owners: nil, classifierIDs: nil, threshold: nil, language: "en", failure: { error in
			print(error)
			completion()
		}) { classifiedImages in
			print("Classifying done - Results:")
			print(classifiedImages)

			if let classifications = classifiedImages.images.first?.classifiers.first?.classes {
				if classifications.count > 0 {
					self.classifications = classifications
					self.sections.append("Classes")
					modelDidChange()
				}
			}

			print("Start face detection...")
			self.visualRecognition.detectFaces(inImageFile: imageFileURL, failure: { error in
				print(error)
				completion()
			}) { imagesWithFaces in
				print("Faces detection done - Results:")
				print(imagesWithFaces)

				if let faces = imagesWithFaces.images.first?.faces {
					if faces.count > 0 {
						self.faces = faces
						self.sections.append("Faces")

						for face in faces {
							self.facesPics.append(self.extractSubImage(CGRect(x: face.location.left, y: face.location.top, width: face.location.width, height: face.location.height), image: UIImage(contentsOfFile: imageFileURL.relativePath)!))
						}
						modelDidChange()
					}
				}

				completion()
			}
		}
	}

	fileprivate func extractSubImage(_ cropRect: CGRect, image: UIImage) -> UIImage {
		let imageRef = image.cgImage!.cropping(to: cropRect)
		let image = UIImage(cgImage: imageRef!, scale: image.scale, orientation: image.imageOrientation)

		return image
	}
}

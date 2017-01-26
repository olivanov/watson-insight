//
//  DocumentInputView.swift
//  WatsonInsight
//
//  Created by Oleg Ivanov on 22.09.16.
//  Copyright © 2016 IBM. All rights reserved.
//

import UIKit
import DocumentConversionV1

class DocumentInputView: UIViewController, UITextViewDelegate {

	@IBOutlet weak var activityIndicator: WatsonActivityView!
	@IBOutlet weak var textView: UITextView!
	@IBOutlet weak var nextButton: UIBarButtonItem!

	var documentURL: URL!
	let documentConversion = DocumentConversion(
		username: BluemixAccess.credentials().documentConversionUsername!,
		password: BluemixAccess.credentials().documentConversionPassword!,
		version: BluemixAccess.credentials().documentConversionVersion!)

    override func viewDidLoad() {
        super.viewDidLoad()

		textView.text = ""
		textView.delegate = self
		textView.returnKeyType = .done

		convertDocumentToPlainText()
	}

	func convertDocumentToPlainText() {

		if !Reachability()!.isReachable {
			AlertUtil.displayAlert(self, title: "No internet connection", message: "Internet connection is required to reach Watson")
			cleanup()
			return
		}

		activityIndicator.startAnimating()
		navigationItem.hidesBackButton = true
		do {
			let config = try self.documentConversion.writeConfig(type: ReturnType.text)
			documentConversion.convertDocument(documentURL, withConfigurationFile: config, failure: { error in
				print(error)
				DispatchQueue.main.async() {
					self.cleanup()
				}
			}) { text in
				print(text)
				DispatchQueue.main.async() {
					self.textView.text = text
					self.textView.setContentOffset(CGPoint.zero, animated: false)
					self.cleanup()
				}
			}
		} catch let error {
			self.cleanup()
			print(error)
		}
	}

	func cleanup() {
		navigationItem.hidesBackButton = false
		if self.textView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) != "" {
			self.nextButton.isEnabled = true
		}
		self.activityIndicator.stopAnimating()
		self.activityIndicator.isHidden = true

		do {
			try FileManager.default.removeItem(at: documentURL)
		} catch let error {
			print(error)
		}
	}

	func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
		if text == "\n" {
			textView.resignFirstResponder()
			return false
		}
		return true
	}

	func textViewDidChange(_ textView: UITextView) {
		if textView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) != "" {
			nextButton.isEnabled = true
		} else {
			nextButton.isEnabled = false
		}
	}

    // MARK: - Navigation

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		let textAnalysisView = segue.destination as! TextAnalysisView

		textAnalysisView.inputText = textView.text
	}
}

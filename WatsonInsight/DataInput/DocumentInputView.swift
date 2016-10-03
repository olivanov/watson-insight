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

	var documentURL: NSURL!
	let documentConversion = DocumentConversion(
		username: BluemixAccess.credentials().documentConversionUsername!,
		password: BluemixAccess.credentials().documentConversionPassword!,
		version: BluemixAccess.credentials().documentConversionVersion!)

    override func viewDidLoad() {
        super.viewDidLoad()

		textView.text = ""
		textView.delegate = self
		textView.returnKeyType = .Done

		convertDocumentToPlainText()
	}

	func convertDocumentToPlainText() {
		if !Reachability.isReachable() {
			AlertUtil.displayAlert(self, title: "No internet connection", message: "Internet connection is required to reach Watson")
			cleanup()
			return
		}

		activityIndicator.startAnimating()
		navigationItem.hidesBackButton = true
		do {
			let config = try self.documentConversion.writeConfig(ReturnType.Text)
			documentConversion.convertDocument(config, document: documentURL, failure: { error in
				print(error)
				self.cleanup()
			}) { text in
				print(text)
				self.textView.text = text
				self.textView.setContentOffset(CGPointZero, animated: false)
				self.cleanup()
			}
		} catch let error {
			self.cleanup()
			print(error)
		}
	}

	func cleanup() {
		navigationItem.hidesBackButton = false
		if self.textView.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) != "" {
			self.nextButton.enabled = true
		}
		self.activityIndicator.stopAnimating()
		self.activityIndicator.hidden = true

		do {
			try NSFileManager.defaultManager().removeItemAtURL(documentURL)
		} catch let error {
			print(error)
		}
	}

	func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
		if text == "\n" {
			textView.resignFirstResponder()
			return false
		}
		return true
	}

	func textViewDidChange(textView: UITextView) {
		if textView.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) != "" {
			nextButton.enabled = true
		} else {
			nextButton.enabled = false
		}
	}

    // MARK: - Navigation

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		let textAnalysisView = segue.destinationViewController as! TextAnalysisView

		textAnalysisView.inputText = textView.text
	}
}

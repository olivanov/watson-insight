//
//  ComposeInputView.swift
//  WatsonInsight
//
//  Created by Oleg Ivanov on 29.09.16.
//  Copyright © 2016 IBM. All rights reserved.
//

import UIKit

class ComposeInputView: UIViewController, UITextViewDelegate {
	@IBOutlet weak var textView: UITextView!
	@IBOutlet weak var nextButton: UIBarButtonItem!

	var inputText: String? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

		if let inputText = inputText {
			textView.text = inputText
			textView.setContentOffset(CGPointZero, animated: false)
			navigationItem.title = "Edit"
			nextButton.enabled = true
		} else {
			textView.text = ""
			textView.becomeFirstResponder()
		}

		textView.delegate = self
		textView.returnKeyType = .Done
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

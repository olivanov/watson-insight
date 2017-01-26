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
			textView.setContentOffset(CGPoint.zero, animated: false)
			navigationItem.title = "Edit"
			nextButton.isEnabled = true
		} else {
			textView.text = ""
			textView.becomeFirstResponder()
		}

		textView.delegate = self
		textView.returnKeyType = .done
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

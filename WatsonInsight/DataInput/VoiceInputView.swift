//
//  VoiceInputView.swift
//  WatsonInsight
//
//  Created by Oleg Ivanov on 21.09.16.
//  Copyright © 2016 IBM. All rights reserved.
//

import UIKit
import SpeechToTextV1
import AVFoundation

class VoiceInputView: UIViewController, UITextViewDelegate {

	@IBOutlet weak var activityIndicator: UIImageView!
	@IBOutlet weak var recButton: UIButton!
	@IBOutlet weak var nextButton: UIBarButtonItem!
	@IBOutlet weak var textView: UITextView!

	var isRecording = false
	let speechToTextSession = SpeechToTextSession(
		username: BluemixAccess.credentials().speechToTextUsername!,
		password: BluemixAccess.credentials().speechToTextPassword!)

	override func viewDidLoad() {
		super.viewDidLoad()

		textView.text = ""
		textView.delegate = self
		textView.returnKeyType = .Done

		// Define callbacks
		speechToTextSession.onConnect = connectHandler
		speechToTextSession.onDisconnect = disconnectHandler
		speechToTextSession.onError = errorHandler
		speechToTextSession.onPowerData = powerDataHandler
		speechToTextSession.onResults = resultsHandler
	}

	@IBAction func recButtonDidPress(sender: UIButton) {
		if !isRecording {
			let session: AVAudioSession = AVAudioSession.sharedInstance()
			session.requestRecordPermission() { allowed in
				if !allowed {
					AlertUtil.displayAlert(self, title: "No microphone available", message: "Please authorize access to the microphone")
					return
				} else {
					if !Reachability.isReachable() {
						AlertUtil.displayAlert(self, title: "No internet connection", message: "Internet connection is required to reach Watson")
						return
					}

					var settings = RecognitionSettings(contentType: .Opus)
					settings.interimResults = true
					settings.continuous = true

					self.recButton.enabled = false

					self.speechToTextSession.connect()
					self.speechToTextSession.startRequest(settings)
					self.speechToTextSession.startMicrophone()
				}
			}
		} else {
			self.recButton.enabled = false
			speechToTextSession.stopMicrophone()
			speechToTextSession.stopRequest()
			speechToTextSession.disconnect()
		}
	}

	func connectHandler() {
		navigationItem.hidesBackButton = true
		nextButton.enabled = false
		textView.editable = false
		activityIndicator.image = UIImage(named: "watsonListening0")
		recButton.setImage(UIImage(named: "recOn"), forState: .Normal)
		isRecording = true
		recButton.enabled = true
		print("connected")
	}

	func disconnectHandler() {
		navigationItem.hidesBackButton = false
		textView.editable = true
		if textView.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) != "" {
			nextButton.enabled = true
		}
		activityIndicator.image = UIImage(named: "watsonLogo")
		recButton.setImage(UIImage(named: "recOff"), forState: .Normal)
		isRecording = false
		recButton.enabled = true
		print("disconnected")
	}

	func errorHandler(error: NSError) {
		speechToTextSession.stopMicrophone()
		speechToTextSession.stopRequest()
		speechToTextSession.disconnect()

		navigationItem.hidesBackButton = false
		disconnectHandler()
		print(error)
	}

	func powerDataHandler(decibels: Float32) {
		if isRecording {
			let level = min(6, max(0, Int(6 + decibels/10)))
			activityIndicator.image = UIImage(named: "watsonListening" + level.description)
		}
	}

	func resultsHandler(results: SpeechRecognitionResults) {
		textView.text = results.bestTranscript
		print(results.bestTranscript)
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

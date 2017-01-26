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
		textView.returnKeyType = .done

		// Define callbacks
		speechToTextSession.onConnect = connectHandler
		speechToTextSession.onDisconnect = disconnectHandler
		speechToTextSession.onError = errorHandler
		speechToTextSession.onPowerData = powerDataHandler
		speechToTextSession.onResults = resultsHandler
	}

	@IBAction func recButtonDidPress(_ sender: UIButton) {
		if !isRecording {
			let session: AVAudioSession = AVAudioSession.sharedInstance()
			session.requestRecordPermission() { allowed in
				if !allowed {
					AlertUtil.displayAlert(self, title: "No microphone available", message: "Please authorize access to the microphone")
					return
				} else {
					if !Reachability()!.isReachable {
						AlertUtil.displayAlert(self, title: "No internet connection", message: "Internet connection is required to reach Watson")
						return
					}

					var settings = RecognitionSettings(contentType: .opus)
					settings.interimResults = true
					settings.continuous = true

					self.recButton.isEnabled = false

					try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
					try? AVAudioSession.sharedInstance().setActive(true)

					self.speechToTextSession.connect()
					self.speechToTextSession.startRequest(settings: settings)
					self.speechToTextSession.startMicrophone()

				}
			}
		} else {
			self.recButton.isEnabled = false
			speechToTextSession.stopMicrophone()
			speechToTextSession.stopRequest()
			speechToTextSession.disconnect()
		}
	}

	func connectHandler() {
		navigationItem.hidesBackButton = true
		nextButton.isEnabled = false
		textView.isEditable = false
		activityIndicator.image = UIImage(named: "watsonListening0")
		recButton.setImage(UIImage(named: "recOn"), for: UIControlState())
		isRecording = true
		recButton.isEnabled = true
		print("connected")
	}

	func disconnectHandler() {
		navigationItem.hidesBackButton = false
		textView.isEditable = true
		if textView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) != "" {
			nextButton.isEnabled = true
		}
		activityIndicator.image = UIImage(named: "watsonLogo")
		recButton.setImage(UIImage(named: "recOff"), for: UIControlState())
		isRecording = false
		recButton.isEnabled = true
		print("disconnected")
	}

	func errorHandler(_ error: Error) {
		speechToTextSession.stopMicrophone()
		speechToTextSession.stopRequest()
		speechToTextSession.disconnect()

		navigationItem.hidesBackButton = false
		disconnectHandler()
		print(error)
	}

	func powerDataHandler(_ decibels: Float32) {
		if isRecording {
			let level = min(6, max(0, Int(6 + decibels/10)))
				activityIndicator.image = UIImage(named: "watsonListening" + level.description)
		}
	}

	func resultsHandler(_ results: SpeechRecognitionResults) {
		textView.text = results.bestTranscript
		print(results.bestTranscript)
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

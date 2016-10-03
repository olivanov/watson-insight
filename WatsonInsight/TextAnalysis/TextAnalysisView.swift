//
//  TextAnalysisView.swift
//  WatsonInsight
//
//  Created by Oleg Ivanov on 21.09.16.
//  Copyright © 2016 IBM. All rights reserved.
//

import UIKit
import TextToSpeechV1
import AVFoundation

class TextAnalysisView: UIViewController, AVAudioPlayerDelegate, UINavigationControllerDelegate, AnalysisSelectionViewDelegate {

	@IBOutlet weak var textView: UITextView!

	var inputText: String!
	let textToSpeech = TextToSpeech(
		username: BluemixAccess.credentials().textToSpeechUsername!,
		password: BluemixAccess.credentials().textToSpeechPassword!)
	var audioPlayer: AVAudioPlayer? = nil
	
    override func viewDidLoad() {
        super.viewDidLoad()

		textView.text = inputText
		navigationController?.delegate = self

		initializePlayButton()
    }

	override func viewDidLayoutSubviews() {
		textView.setContentOffset(CGPointZero, animated: false)
	}

	func initializePlayButton() {
		let playButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Play, target: self, action: #selector(play(_:)))
		self.navigationItem.rightBarButtonItem = playButton
	}

	func play(sender: UIBarButtonItem) {
		if !Reachability.isReachable() {
			AlertUtil.displayAlert(self, title: "No internet connection", message: "Internet connection is required to reach Watson")
			return
		}

		let subText = textView.text.substringToIndex(textView.text.startIndex.advancedBy(min(textView.text.characters.count, 1024)))
		navigationItem.rightBarButtonItem?.enabled = false
		textToSpeech.synthesize(subText, voice: SynthesisVoice.US_Allison, failure: { error in
			self.navigationItem.rightBarButtonItem?.enabled = true
			AlertUtil.displayAlert(self, title: "Error", message: error.localizedFailureReason!)
		}) { data in
			do {
				self.audioPlayer = try AVAudioPlayer(data: data)
			} catch let error {
				print(error)
				return
			}

			self.navigationItem.rightBarButtonItem?.enabled = true

			self.audioPlayer?.delegate = self
			self.audioPlayer?.prepareToPlay()
			self.audioPlayer?.play()

			let pauseButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Pause, target: self, action: #selector(self.pause(_:)))
			self.navigationItem.rightBarButtonItem = pauseButton
		}
	}

	func resume(sender: UIBarButtonItem) {
		audioPlayer?.play()

		let pauseButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Pause, target: self, action: #selector(pause(_:)))
		navigationItem.rightBarButtonItem = pauseButton
	}

	func pause(sender: UIBarButtonItem){
		audioPlayer?.pause()

		let resumeButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Play, target: self, action: #selector(resume(_:)))
		navigationItem.rightBarButtonItem = resumeButton
	}

	func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
		initializePlayButton()
	}

	func textToAnalyse() -> String {
		return textView.text
	}

	func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
		audioPlayer?.stop()
	}

    // MARK: - Navigation

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		let analysisSelectionView = segue.destinationViewController as! AnalysisSelectionView
		analysisSelectionView.delegate = self
	}
}

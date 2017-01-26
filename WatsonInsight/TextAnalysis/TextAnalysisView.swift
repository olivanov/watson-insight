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
		textView.setContentOffset(CGPoint.zero, animated: false)
	}

	func initializePlayButton() {
		let playButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.play, target: self, action: #selector(play(_:)))
		self.navigationItem.rightBarButtonItem = playButton
	}

	func play(_ sender: UIBarButtonItem) {
		if !Reachability()!.isReachable {
			AlertUtil.displayAlert(self, title: "No internet connection", message: "Internet connection is required to reach Watson")
			return
		}

		let subText = textView.text.substring(to: textView.text.index(textView.text.startIndex, offsetBy: min(textView.text.characters.count, 2048)))
		navigationItem.rightBarButtonItem?.isEnabled = false
		textToSpeech.synthesize(subText, voice: SynthesisVoice.us_Allison.rawValue, failure: { error in
			DispatchQueue.main.async() {
				self.navigationItem.rightBarButtonItem?.isEnabled = true
				AlertUtil.displayAlert(self, title: "Error", message: error.localizedDescription)
			}
		}) { data in
			do {
				self.audioPlayer = try AVAudioPlayer(data: data)
			} catch let error {
				print(error)
				return
			}

			self.navigationItem.rightBarButtonItem?.isEnabled = true

			self.audioPlayer?.delegate = self
			self.audioPlayer?.prepareToPlay()
			self.audioPlayer?.play()
			
			try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)

			DispatchQueue.main.async() {
				let pauseButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.pause, target: self, action: #selector(self.pause(_:)))
				self.navigationItem.rightBarButtonItem = pauseButton
			}
		}
	}

	func resume(_ sender: UIBarButtonItem) {
		audioPlayer?.play()

		let pauseButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.pause, target: self, action: #selector(pause(_:)))
		navigationItem.rightBarButtonItem = pauseButton
	}

	func pause(_ sender: UIBarButtonItem){
		audioPlayer?.pause()

		let resumeButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.play, target: self, action: #selector(resume(_:)))
		navigationItem.rightBarButtonItem = resumeButton
	}

	func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
		initializePlayButton()
	}

	func textToAnalyse() -> String {
		return textView.text
	}

	func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
		audioPlayer?.stop()
	}

    // MARK: - Navigation

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		let analysisSelectionView = segue.destination as! AnalysisSelectionView
		analysisSelectionView.delegate = self
	}
}

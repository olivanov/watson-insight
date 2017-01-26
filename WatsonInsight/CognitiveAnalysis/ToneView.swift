//
//  ToneView.swift
//  WatsonInsight
//
//  Created by Oleg Ivanov on 27.09.16.
//  Copyright © 2016 IBM. All rights reserved.
//

import UIKit
import ToneAnalyzerV3

class ToneView: UITableViewController {

	var inputText: String!
	var documentTone: [ToneCategory]? = nil

	let toneAnalyzer = ToneAnalyzer(
		username: BluemixAccess.credentials().toneAnalyzerUsername!,
		password: BluemixAccess.credentials().toneAnalyzerPassword!,
		version: BluemixAccess.credentials().toneAnalyzerVersion!)

    override func viewDidLoad() {
        super.viewDidLoad()

		let activityView = WatsonActivityView(frame: view.bounds)
		view.addSubview(activityView)
		activityView.startAnimating()

		toneAnalyzer.defaultHeaders = ["Accept-Language":"en"]
		toneAnalyzer.getTone(ofText: inputText, failure: { error in
			DispatchQueue.main.async {
				_ = self.navigationController?.popViewController(animated: true)
				AlertUtil.displayAlert(self.navigationController!, title: "Error", message: error.localizedDescription)
			}
			print(error)
		}) { tones in
			DispatchQueue.main.async {
				activityView.stopAnimating()
				activityView.removeFromSuperview()

				self.documentTone = tones.documentTone
				self.tableView.reloadData()
			}
			print(tones)
		}
    }

	// MARK: - Table view data source

	override func numberOfSections(in tableView: UITableView) -> Int {
		guard documentTone != nil else { return 0 }

		return documentTone!.count
	}

	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return documentTone![section].name
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return documentTone![section].tones.count
	}

	override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
		let header = view as! UITableViewHeaderFooterView
		header.contentView.backgroundColor = UIColor(red: 120/255, green: 186/255, blue: 40/255, alpha: 1.0)
		header.textLabel!.textColor = UIColor.white
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: "toneCell") as? CognitiveCell else { return UITableViewCell() }

		let tone = documentTone![indexPath.section].tones[indexPath.row]

		cell.caracteristicLabel.text = tone.name
		cell.scoreProgressView.setProgress(Float(tone.score), animated: false)

		return cell
	}
}

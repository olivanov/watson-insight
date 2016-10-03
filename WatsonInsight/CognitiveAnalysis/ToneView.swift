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

		toneAnalyzer.getTone(inputText, failure: { error in
			self.navigationController?.popViewControllerAnimated(true)
			AlertUtil.displayAlert(self.navigationController!, title: "Error", message: error.localizedFailureReason!)
			print(error)
		}) { tones in
			activityView.stopAnimating()
			activityView.removeFromSuperview()

			self.documentTone = tones.documentTone
			self.tableView.reloadData()

			print(tones)
		}
    }

	// MARK: - Table view data source

	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		guard documentTone != nil else { return 0 }

		return documentTone!.count
	}

	override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return documentTone![section].name
	}

	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return documentTone![section].tones.count
	}

	override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
		let header = view as! UITableViewHeaderFooterView
		header.contentView.backgroundColor = UIColor(red: 120/255, green: 186/255, blue: 40/255, alpha: 1.0)
		header.textLabel!.textColor = UIColor.whiteColor()
	}

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCellWithIdentifier("toneCell") as? CognitiveCell else { return UITableViewCell() }

		let tone = documentTone![indexPath.section].tones[indexPath.row]

		cell.caracteristicLabel.text = tone.name
		cell.scoreProgressView.setProgress(Float(tone.score), animated: false)

		return cell
	}
}

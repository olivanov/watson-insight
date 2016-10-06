//
//  AnalysisSelectionView.swift
//  WatsonInsight
//
//  Created by Oleg Ivanov on 28.09.16.
//  Copyright © 2016 IBM. All rights reserved.
//

import UIKit

protocol AnalysisSelectionViewDelegate {
	func textToAnalyse() -> String
}

class AnalysisSelectionView: UITableViewController {

	var delegate: AnalysisSelectionViewDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

		tableView.tableFooterView = UIView(frame: CGRect.zero)
    }

	override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
		let header = view as! UITableViewHeaderFooterView
		header.contentView.backgroundColor = UIColor(red: 120/255, green: 186/255, blue: 40/255, alpha: 1.0)
		header.textLabel!.textColor = UIColor.whiteColor()
	}

	// MARK: - Navigation

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		print(segue.identifier)

		switch segue.identifier! {
		case "toToneView":
			let toneView = segue.destinationViewController as! ToneView
			toneView.inputText = delegate?.textToAnalyse()
		case "toPersonalityView":
			let personalityView = segue.destinationViewController as! PersonalityView
			personalityView.inputText = delegate?.textToAnalyse()
		default:
			break
		}
	}

	override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
		if !Reachability.isReachable() {
			AlertUtil.displayAlert(self, title: "No internet connection", message: "Internet connection is required to reach Watson")
			return false
		} else {
			return true
		}
	}
}

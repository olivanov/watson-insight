//
//  PersonalityView.swift
//  WatsonInsight
//
//  Created by Oleg Ivanov on 29.09.16.
//  Copyright © 2016 IBM. All rights reserved.
//

import UIKit
import PersonalityInsightsV2

class PersonalityView: UITableViewController {

	var inputText: String!
	var tree: TraitTreeNode? = nil
	var isRootLevel = true
	var navigationTitle: String? = nil

	let personalityInsights = PersonalityInsights(username: BluemixAccess.credentials().personalityInsightsUsername!, password: BluemixAccess.credentials().personalityInsightsPassword!)

	override func viewDidLoad() {
		super.viewDidLoad()

		tableView.dataSource = self
		tableView.tableFooterView = UIView(frame: CGRect.zero)

		if tree == nil {
			let activityView = WatsonActivityView(frame: view.bounds)
			view.addSubview(activityView)
			activityView.startAnimating()

			personalityInsights.getProfile(text: inputText, acceptLanguage: NSLocale.preferredLanguages().first!, contentLanguage: "en", failure: { error in
				self.navigationController?.popViewControllerAnimated(true)
				AlertUtil.displayAlert(self.navigationController!, title: "Error", message: error.localizedFailureReason!)
				print(error)
			}) { profile in

				activityView.stopAnimating()
				activityView.removeFromSuperview()

				self.tree = profile.tree
				self.tableView.reloadData()

				print(profile)
			}
		} else {
			isRootLevel = false
			navigationItem.title = navigationTitle
		}
	}

	// MARK: - Table view data source

	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		guard let tree = tree else { return 0 }

		if isRootLevel {
			return tree.children!.count
		} else {
			return 1
		}
	}

	override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if isRootLevel {
			return tree!.children![section].name
		} else {
			return nil
		}
	}

	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if isRootLevel {
			return tree!.children![section].children![0].children!.count
		} else {
			return tree!.children!.count
		}
	}

	override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
		let header = view as! UITableViewHeaderFooterView
		header.contentView.backgroundColor = UIColor(red: 120/255, green: 186/255, blue: 40/255, alpha: 1.0)
		header.textLabel!.textColor = UIColor.whiteColor()
	}

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCellWithIdentifier("personalityCell") as? CognitiveCell else { return UITableViewCell() }

		let node: TraitTreeNode
		if isRootLevel {
			node = tree!.children![indexPath.section].children![0].children![indexPath.row]
		} else {
			node = tree!.children![indexPath.row]
		}

		cell.caracteristicLabel.text = node.name
		cell.scoreProgressView.setProgress(Float(node.percentage!), animated: false)

		if node.children != nil {
			cell.accessoryType = .DisclosureIndicator
		} else {
			cell.accessoryType = .None
		}

		return cell
	}

    // MARK: - Navigation

	override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
		let indexPath = tableView.indexPathForSelectedRow!
		if isRootLevel && tree?.children![indexPath.section].children![0].children![indexPath.row].children != nil {
			return true
		} else {
			return false
		}
	}

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		let indexPath = tableView.indexPathForSelectedRow!
		let subTree = tree?.children![indexPath.section].children![0].children![indexPath.row]
		let personalityView = segue.destinationViewController as! PersonalityView
		personalityView.tree = subTree
		personalityView.isRootLevel = false
		personalityView.navigationTitle = subTree?.name
	}
}

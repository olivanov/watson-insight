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

			personalityInsights.getProfile(fromText: inputText, acceptLanguage: Locale.preferredLanguages.first!, contentLanguage: "en", includeRaw: nil, failure: { error in
				DispatchQueue.main.async {
					_ = self.navigationController?.popViewController(animated: true)
					AlertUtil.displayAlert(self.navigationController!, title: "Error", message: error.localizedDescription)
				}
				print(error)
			}) { profile in

				DispatchQueue.main.async {
					activityView.stopAnimating()
					activityView.removeFromSuperview()

					self.tree = profile.tree
					self.tableView.reloadData()
				}

				print(profile)
			}
		} else {
			isRootLevel = false
			navigationItem.title = navigationTitle
		}
	}

	// MARK: - Table view data source

	override func numberOfSections(in tableView: UITableView) -> Int {
		guard let tree = tree else { return 0 }

		if isRootLevel {
			return tree.children!.count
		} else {
			return 1
		}
	}

	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if isRootLevel {
			return tree!.children![section].name
		} else {
			return nil
		}
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if isRootLevel {
			return tree!.children![section].children![0].children!.count
		} else {
			return tree!.children!.count
		}
	}

	override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
		let header = view as! UITableViewHeaderFooterView
		header.contentView.backgroundColor = UIColor(red: 120/255, green: 186/255, blue: 40/255, alpha: 1.0)
		header.textLabel!.textColor = UIColor.white
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: "personalityCell") as? CognitiveCell else { return UITableViewCell() }

		let node: TraitTreeNode
		if isRootLevel {
			node = tree!.children![indexPath.section].children![0].children![indexPath.row]
		} else {
			node = tree!.children![indexPath.row]
		}

		cell.caracteristicLabel.text = node.name
		cell.scoreProgressView.setProgress(Float(node.percentage!), animated: false)

		if node.children != nil {
			cell.accessoryType = .disclosureIndicator
		} else {
			cell.accessoryType = .none
		}

		return cell
	}

    // MARK: - Navigation

	override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
		let indexPath = tableView.indexPathForSelectedRow!
		if isRootLevel && tree?.children![indexPath.section].children![0].children![indexPath.row].children != nil {
			return true
		} else {
			return false
		}
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		let indexPath = tableView.indexPathForSelectedRow!
		let subTree = tree?.children![indexPath.section].children![0].children![indexPath.row]
		let personalityView = segue.destination as! PersonalityView
		personalityView.tree = subTree
		personalityView.isRootLevel = false
		personalityView.navigationTitle = subTree?.name
	}
}

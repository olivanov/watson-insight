//
//  AlertUtil.swift
//  WatsonInsight
//
//  Created by Oleg Ivanov on 29.09.16.
//  Copyright © 2016 IBM. All rights reserved.
//

import UIKit

class AlertUtil {
	static func displayAlert(_ controller: UIViewController, title: String, message: String) {
		let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
		let action = UIAlertAction(title: "OK", style: .default, handler: nil)
		alertController.addAction(action)

		controller.present(alertController, animated: true, completion: nil)
	}
}

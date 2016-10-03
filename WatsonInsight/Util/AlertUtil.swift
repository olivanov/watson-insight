//
//  AlertUtil.swift
//  WatsonInsight
//
//  Created by Oleg Ivanov on 29.09.16.
//  Copyright © 2016 IBM. All rights reserved.
//

import UIKit

class AlertUtil {
	static func displayAlert(controller: UIViewController, title: String, message: String) {
		let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
		let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
		alertController.addAction(action)

		controller.presentViewController(alertController, animated: true, completion: nil)
	}
}

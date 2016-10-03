//
//  WatsonActivityView.swift
//  WatsonInsight
//
//  Created by Oleg Ivanov on 29.09.16.
//  Copyright © 2016 IBM. All rights reserved.
//

import UIKit

class WatsonActivityView: UIImageView {
	override init(frame: CGRect) {
		super.init(frame: frame)
		loadImages()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		loadImages()
	}

	func loadImages() {
		animationImages = [
			UIImage(named: "watsonThinking1")!,
			UIImage(named: "watsonThinking2")!,
			UIImage(named: "watsonThinking3")!,
			UIImage(named: "watsonThinking4")!,
			UIImage(named: "watsonThinking5")!,
			UIImage(named: "watsonThinking4")!,
			UIImage(named: "watsonThinking3")!,
			UIImage(named: "watsonThinking2")!]
		animationDuration = 1

		contentMode = .Center
	}
}

//
//  ClassificationCell.swift
//  WatsonInsight
//
//  Created by Oleg Ivanov on 16.09.16.
//  Copyright © 2016 IBM. All rights reserved.
//

import UIKit

class ClassificationCell: UITableViewCell {

	@IBOutlet weak var classificationLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

	func setScoreOpacity(opacity: Double) {
		classificationLabel.alpha = CGFloat(opacity)
	}

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

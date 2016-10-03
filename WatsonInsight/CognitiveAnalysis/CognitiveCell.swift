//
//  CognitiveCell.swift
//  WatsonInsight
//
//  Created by Oleg Ivanov on 29.09.16.
//  Copyright © 2016 IBM. All rights reserved.
//

import UIKit

class CognitiveCell: UITableViewCell {
	@IBOutlet weak var caracteristicLabel: UILabel!
	@IBOutlet weak var scoreProgressView: UIProgressView!

    override func awakeFromNib() {
        super.awakeFromNib()

		scoreProgressView.transform = CGAffineTransformMakeScale(1, 6)
    }
}

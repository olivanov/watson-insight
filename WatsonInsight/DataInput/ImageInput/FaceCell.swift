//
//  FaceCell.swift
//  WatsonInsight
//
//  Created by Oleg Ivanov on 16.09.16.
//  Copyright © 2016 IBM. All rights reserved.
//

import UIKit

class FaceCell: UITableViewCell {
	@IBOutlet weak var faceImageView: UIImageView!

	@IBOutlet weak var genderLabel: UILabel!

	@IBOutlet weak var ageLabel: UILabel!
	
    override func awakeFromNib() {
        super.awakeFromNib()

		faceImageView.layer.cornerRadius = 5
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

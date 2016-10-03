//
//  ImageUtil.swift
//  WatsonInsight
//
//  Created by Oleg Ivanov on 16.09.16.
//  Copyright © 2016 IBM. All rights reserved.
//

import Foundation
import UIKit

class ImageUtil {
	static func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage?
	{
		let size = image.size

		let widthRatio  = targetSize.width  / image.size.width
		let heightRatio = targetSize.height / image.size.height

		var newSize: CGSize
		if(widthRatio > heightRatio) {
			newSize = CGSizeMake(size.width * heightRatio, size.height * heightRatio)
		} else {
			newSize = CGSizeMake(size.width * widthRatio,  size.height * widthRatio)
		}

		let rect = CGRectMake(0, 0, newSize.width, newSize.height)

		UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
		image.drawInRect(rect)
		let newImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()

		return newImage
	}
}

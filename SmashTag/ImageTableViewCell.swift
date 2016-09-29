//
//  ImageTableViewCell.swift
//  SmashTag
//
//  Created by Danil Denshin on 05.09.16.
//  Copyright © 2016 el2Nil. All rights reserved.
//

import UIKit

var count: Int = 0

class ImageTableViewCell: UITableViewCell {
	
	@IBOutlet weak var tweetImage: UIImageView!
	@IBOutlet weak var spinner: UIActivityIndicatorView!
	
	var imageURL: NSURL? {
		didSet {
			updateUI()
		}
	}
	
	private func updateUI() {
		spinner.startAnimating()
		if let url = imageURL {
			dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
				[weak weakSelf = self] in
				let imageData = NSData(contentsOfURL: url)
				if url == weakSelf?.imageURL {
					dispatch_async(dispatch_get_main_queue()) {
						if let imageData = imageData {
							weakSelf?.tweetImage.image = UIImage(data: imageData)
						}
						weakSelf?.spinner.stopAnimating()
					}
				}
			}
		}
	}
	
		
}

//
//  ImageCollectionViewCell.swift
//  SmashTag
//
//  Created by Danil Denshin on 06.09.16.
//  Copyright © 2016 el2Nil. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
	@IBOutlet weak var spinner: UIActivityIndicatorView!
	@IBOutlet weak var imageView: UIImageView!
	
	var cache: NSCache?
	
	var tweetMedia: TweetMedia? {
		didSet {
			imageURL = tweetMedia?.media.url
			fetchImage()
		}
	}
	
	var imageURL: NSURL?
	
	var image: UIImage? {
		get { return imageView.image }
		set {
			imageView.image = newValue
			spinner.stopAnimating()
		}
	}
	
	private func fetchImage() {
		if let url = imageURL {
			spinner?.startAnimating()
			let imageData = cache?.objectForKey(url) as? NSData
			guard imageData == nil else { image = UIImage(data: imageData!); return }
			
			dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
				let contentsOfURL = NSData(contentsOfURL: url)
				dispatch_async(dispatch_get_main_queue()) {
					if url == self.imageURL {
						if let imageData = contentsOfURL {
							self.image = UIImage(data: imageData)
							self.cache?.setObject(imageData, forKey: url, cost: imageData.length / 1024)
						} else {
							self.spinner?.stopAnimating()
						}
					} else {
						print("Image cell: ignored data returned from url \(url)")
					}
				}
			}
		}
	}
	
}

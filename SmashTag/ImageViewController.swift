//
//  ImageViewController.swift
//  Cassini
//
//  Created by Danil Denshin on 25.08.16.
//  Copyright © 2016 el2Nil. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController, UIScrollViewDelegate
{
	@IBOutlet weak var spinner: UIActivityIndicatorView!
	
	@IBOutlet weak var scrollView: UIScrollView! {
		didSet {
			scrollView.contentSize = imageView.frame.size
			scrollView.delegate = self
			scrollView.minimumZoomScale = 0.03
			scrollView.maximumZoomScale = 1.0
		}
	}
	
	private var autoZoom: Bool = true
	
	private func zoomScaleToFit() {
		if !autoZoom {
			return
		}
		if let sv = scrollView where image != nil && (imageView.bounds.size.height > 0)
			&& (scrollView.bounds.size.height > 0) {
			let widthRatio = scrollView.bounds.size.width / imageView.bounds.size.width
			let heightRatio = scrollView.bounds.size.height / imageView.bounds.size.height
			sv.zoomScale = min(widthRatio, heightRatio)
			sv.contentOffset = CGPoint(x: (imageView.frame.size.width - sv.frame.size.width) / 2,
			                           y: (imageView.frame.size.height - sv.frame.size.height) / 2)
		}
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		zoomScaleToFit()
	}
	
	func scrollViewWillBeginZooming(scrollView: UIScrollView, withView view: UIView?) {
		autoZoom = false
	}
	
	var imageURL: NSURL? {
		didSet {
			image = nil
			if view.window != nil {
				fetchImage()
			}
		}
	}
	
	private func fetchImage() {
		if let url = imageURL {
			spinner?.startAnimating()
			dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
				let contentsOfURL = NSData(contentsOfURL: url)
				dispatch_async(dispatch_get_main_queue()) {
					if url == self.imageURL {
						if let imageData = contentsOfURL {
							self.image = UIImage(data: imageData)
						} else {
							self.spinner?.stopAnimating()
						}
					} else {
						print("ignored data returned from url \(url)")
					}
				}
			}
		}
	}
	
	func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
		return imageView
	}
	
	private var imageView = UIImageView()
	
	private var image: UIImage? {
		get {
			return imageView.image
		}
		set {
			imageView.image = newValue
			imageView.sizeToFit()
			scrollView?.contentSize = imageView.frame.size
			spinner?.stopAnimating()
			autoZoom = true
			zoomScaleToFit()
		}
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		if image == nil {
			fetchImage()
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		scrollView.addSubview(imageView)
	}
}

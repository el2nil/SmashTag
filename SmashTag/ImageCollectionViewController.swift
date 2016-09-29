//
//  ImageCollectionViewController.swift
//  SmashTag
//
//  Created by Danil Denshin on 06.09.16.
//  Copyright © 2016 el2Nil. All rights reserved.
//

import UIKit
import Twitter

private let reuseIdentifier = "Cell"

class ImageCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, CHTCollectionViewDelegateWaterfallLayout {
	
	var scale: CGFloat = 1 {
		didSet {
			collectionView?.collectionViewLayout.invalidateLayout()
		}
	}
	
	private var cache = NSCache()
	private var images = [TweetMedia]()
	
	
	var tweets: [[Twitter.Tweet]] = [] {
		didSet {
			images = tweets.flatMap({$0}).map {	tweet in tweet.media.map { TweetMedia(tweet: tweet, media: $0) }}.flatMap({$0})
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let orginizeButton = UIBarButtonItem(image: UIImage(named: "grid"), style: .Plain, target: self, action: #selector(changeLayout(_:)))
		addBarButton(orginizeButton, side: .Right, order: .Pre)

		setupLayout()
		
		
		collectionView?.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(zoom(_:))))
		installsStandardGestureForInteractiveMovement = true
	}
	
	func changeLayout(sender: UIBarButtonItem) {
		if let layout = collectionView?.collectionViewLayout {
			if layout is CHTCollectionViewWaterfallLayout {
				collectionView?.setCollectionViewLayout(layoutFlow, animated: true)
			} else {
				collectionView?.setCollectionViewLayout(layoutWaterfall, animated: true)
			}
		}
	}
	
	private struct Constants {
		static let CellReuseIdentifier = "Image Cell"
		static let ShowTweetSegue = "Show Tweet"
		
		static let MinImageCellWidth: CGFloat = 60
		static let SizeSetting = CGSize(width: 120, height: 120)
		
		static let ColumnCoutWaterfall = 3
		static let ColumnCountWaterfallMax = 8
		static let ColumnCountWaterfallMin = 1
		
		static let ColumnCount: CGFloat = 3
		
		static let minimumColumnSpacing: CGFloat = 2
		static let minimumInteritemSpacing: CGFloat = 2
		
		static let sectionInset = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
	}
	
	func zoom(gesture: UIPinchGestureRecognizer) {
		if gesture.state == .Changed {
			scale *= gesture.scale
			gesture.scale = 1
		}
	}
	
	// MARK: - Navigation
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == Constants.ShowTweetSegue {
			if let tweetVC = segue.destinationViewController as? TweetTableViewController {
				if let cell = sender as? ImageCollectionViewCell, let tweetMedia = cell.tweetMedia {
					tweetVC.tweets = [[tweetMedia.tweet]]
					let popToRootButton = UIBarButtonItem(barButtonSystemItem: .Stop, target: self, action: Selector.popToRootViewController)
					tweetVC.addBarButton(popToRootButton, side: .Right, order: .Post)
				}
			}
		}
	}
	
	// MARK: UICollectionViewDataSource
	
	override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
		return 1
	}
	
	
	override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return images.count
	}
	
	override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Constants.CellReuseIdentifier, forIndexPath: indexPath)
		if let imageCell = cell as? ImageCollectionViewCell {
			imageCell.cache = cache
			imageCell.tweetMedia = images[indexPath.row]
		}
		
		return cell
	}
	
	var predefinedWidth:CGFloat {return floor(((collectionView?.bounds.width)! -
		Constants.minimumColumnSpacing * (Constants.ColumnCount - 1.0 ) -
		Constants.sectionInset.right * 2.0) / Constants.ColumnCount)}
	
	var sizePredefined:CGSize {return CGSize(width: predefinedWidth, height: predefinedWidth) }
	
	private struct Layout {
		
		
	}
	
	let layoutFlow = UICollectionViewFlowLayout()
	let layoutWaterfall = CHTCollectionViewWaterfallLayout()
	
	private func setupLayout() {
		
		//waterfall
		layoutWaterfall.columnCount = Constants.ColumnCoutWaterfall
		layoutWaterfall.minimumColumnSpacing = Constants.minimumColumnSpacing
		layoutWaterfall.minimumInteritemSpacing = Constants.minimumInteritemSpacing
		
		// flow layout
		layoutFlow.minimumLineSpacing = Constants.minimumColumnSpacing
		layoutFlow.minimumInteritemSpacing = Constants.minimumInteritemSpacing
		layoutFlow.sectionInset = Constants.sectionInset
		layoutFlow.itemSize = sizePredefined
		
		collectionView?.collectionViewLayout = layoutWaterfall
	}
	
	private func ajustWaterfallColumnCount(collectionView: UICollectionView) {
		if let waterfallLoyout = collectionView.collectionViewLayout as? CHTCollectionViewWaterfallLayout {
			let newColumnCount = Int(CGFloat(Constants.ColumnCoutWaterfall) / scale)
			
			waterfallLoyout.columnCount = min(max(Constants.ColumnCountWaterfallMin, newColumnCount), Constants.ColumnCountWaterfallMax)
		}
	}
	
	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
		
		ajustWaterfallColumnCount(collectionView)
		
		let ratio = CGFloat(images[indexPath.row].media.aspectRatio)
		var sizeSetting =  sizePredefined
		var maxCellWidth = collectionView.bounds.size.width
		
		let layoutFlow = collectionViewLayout as? UICollectionViewFlowLayout
		let layoutWaterFall = collectionViewLayout as? CHTCollectionViewWaterfallLayout
		
		if let layout = layoutFlow {
			maxCellWidth = collectionView.bounds.size.width  -
				layout.minimumInteritemSpacing * 2.0 -
				layout.sectionInset.right * 2.0
			sizeSetting = layout.itemSize
		}
		if let layout = layoutWaterFall {
			maxCellWidth = collectionView.bounds.size.width  -
				layout.minimumInteritemSpacing * 2.0 -
				layout.sectionInset.right * 2.0
		}
		let size = CGSize(width: sizeSetting.width * scale,
		                  height: sizeSetting.height * scale)
		let cellWidth = min (max (size.width , Constants.MinImageCellWidth),maxCellWidth)
		return (CGSize(width: cellWidth, height: cellWidth / ratio))
		
	}
	
	override func collectionView(collectionView: UICollectionView, canMoveItemAtIndexPath indexPath: NSIndexPath) -> Bool {
		return true
	}
	
	override func collectionView(collectionView: UICollectionView, moveItemAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
		let temp = images[destinationIndexPath.row]
		images[destinationIndexPath.row] = images[sourceIndexPath.row]
		images[sourceIndexPath.row] = temp
		collectionView.collectionViewLayout.invalidateLayout()
	}
	
	// MARK: UICollectionViewDelegate
	
	/*
	// Uncomment this method to specify if the specified item should be highlighted during tracking
	override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
	return true
	}
	*/
	
	/*
	// Uncomment this method to specify if the specified item should be selected
	override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
	return true
	}
	*/
	
	/*
	// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
	override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
	return false
	}
	
	override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
	return false
	}
	
	override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
	
	}
	*/
	
}

public struct TweetMedia: CustomStringConvertible {
	var tweet: Twitter.Tweet
	var media: Twitter.MediaItem
	
	public var description: String { return "\(tweet): \(media)" }
}

//
//  TweetTableViewCell.swift
//  SmashTag
//
//  Created by Danil Denshin on 04.09.16.
//  Copyright © 2016 el2Nil. All rights reserved.
//

import UIKit
import Twitter

extension NSMutableAttributedString {
	func setMensionsColor(mentions: [Twitter.Mention], color: UIColor) {
		for mention in mentions {
			setAttributes([NSForegroundColorAttributeName: color], range: mention.nsrange)
		}
	}
}

class TweetTableViewCell: UITableViewCell {

	@IBOutlet weak var tweetScreenNameLabel: UILabel!
	@IBOutlet weak var tweetTextLabel: UILabel!
	@IBOutlet weak var tweetCreatedLabel: UILabel!
	@IBOutlet weak var tweetProfileImageView: UIImageView!
	
	var tweet: Twitter.Tweet? {
		didSet {
			updateUI()
		}
	}
	
	private struct tweetColours {
		static let hashtagColour = UIColor.blueColor()
		static let urlColour = UIColor.brownColor()
		static let userColour = UIColor.purpleColor()
	}
	
	private func getColouredTweetText(tweet: Twitter.Tweet) -> NSMutableAttributedString {
		
		var tweetText = tweet.text
		for _ in tweet.media { tweetText += " 📷" }
		let attrText = NSMutableAttributedString(string: tweetText)
		
		attrText.setMensionsColor(tweet.hashtags, color: tweetColours.hashtagColour)
		attrText.setMensionsColor(tweet.urls, color: tweetColours.urlColour)
		attrText.setMensionsColor(tweet.userMentions, color: tweetColours.userColour)

		return attrText
	}
	
	private func updateUI() {
		tweetTextLabel?.attributedText = nil
		tweetScreenNameLabel?.text = nil
		tweetProfileImageView.image = nil
		tweetCreatedLabel.text = nil
		
		if let tweet = self.tweet {
			
			tweetTextLabel.attributedText = getColouredTweetText(tweet)
		
			tweetScreenNameLabel?.text = "\(tweet.user)"
			
			if let profileImageURL = tweet.user.profileImageURL {
//				if let imageData = NSData(contentsOfURL: profileImageURL) {
//					tweetProfileImageView?.image = UIImage(data: imageData)
//				}
				setProfileImage(profileImageURL)
			}
			
			let formatter = NSDateFormatter()
			if NSDate().timeIntervalSinceDate(tweet.created) > 24*60*60 {
				formatter.dateStyle = NSDateFormatterStyle.ShortStyle
			} else {
				formatter.timeStyle = NSDateFormatterStyle.ShortStyle
			}
			tweetCreatedLabel?.text = formatter.stringFromDate(tweet.created)
		}
	}
	
	private func setProfileImage(url: NSURL) {
		dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) { [weak weakSelf = self] in
			if let imageData = NSData(contentsOfURL: url) {
				dispatch_async(dispatch_get_main_queue()) {
					if url == weakSelf?.tweet?.user.profileImageURL {
						weakSelf?.tweetProfileImageView?.image = UIImage(data: imageData)
					}
				}
			}
		}
	}
	

}

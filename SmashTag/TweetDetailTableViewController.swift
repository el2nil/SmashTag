//
//  TweetDetailTableViewController.swift
//  SmashTag
//
//  Created by Danil Denshin on 05.09.16.
//  Copyright © 2016 el2Nil. All rights reserved.
//

import UIKit
import Twitter
import SafariServices

class TweetDetailTableViewController: UITableViewController {
	
	var tweet: Twitter.Tweet? {
		didSet {
			updateSections()
		}
	}
	
	private func updateSections() {
		title = tweet?.user.screenName ?? ""
		if let media = tweet?.media where media.count > 0 {
			mentionSections.append(MentionSection(type: "Images", mentions: media.map { MentionItem.Image($0.url, $0.aspectRatio)}))
		}
		if let hashtags = tweet?.hashtags where hashtags.count > 0 {
			mentionSections.append(MentionSection(type: "Hashtags", mentions: hashtags.map { MentionItem.Keyword($0.keyword) }))
		}
		if let urls = tweet?.urls where urls.count > 0 {
			mentionSections.append(MentionSection(type: "URLs", mentions: urls.map { MentionItem.Keyword($0.keyword)}))
		}
		if let users = tweet?.userMentions {
			var userMentions = [MentionItem]()
			if let screenName = tweet?.user.screenName {
				userMentions += [MentionItem.Keyword("@" + screenName)]
			}
			if users.count > 0 {
				userMentions += users.map { MentionItem.Keyword($0.keyword) }
			}
			if userMentions.count > 0 {
				mentionSections.append(MentionSection(type: "Users", mentions: userMentions))
			}
		}
		
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
	}
	
	// MARK: - Table view data source
	
	override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return mentionSections[section].type
	}
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return mentionSections.count
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return mentionSections[section].mentions.count
	}
	
	private var mentionSections: [MentionSection] = []
	
	private struct MentionSection {
		var type: String
		var mentions: [MentionItem]
	}
	
	private enum MentionItem {
		case Image(NSURL, Double)
		case Keyword(String)
	}
	
	private struct Storyboard {
		static let Image = "Image"
		static let Keyword = "Keyword"
		static let segueFromkeyword = "From Keyword"
		static let ShowImageSegue = "Show Image"
		static let ShowWebSegue = "Show Web"
	}
	
	override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
		if let cell = sender as? UITableViewCell, let indexPath = tableView.indexPathForCell(cell)
			where mentionSections[indexPath.section].type == "URLs" {
				performSegueWithIdentifier(Storyboard.ShowWebSegue, sender: sender)
				return false
		}
		
		return true
		
//		if identifier == Storyboard.segueFromkeyword {
//			if let cell = sender as? UITableViewCell {
//				if let indexPath = tableView.indexPathForCell(cell) {
//					if let urlString = cell.textLabel?.text,
//						let url = NSURL(string: urlString) {
//						if mentionSections[indexPath.section].type == "URLs" {
////							let safariVC = SFSafariViewController(URL: url)
////							presentViewController(safariVC, animated: true, completion: nil)
//
//						}
//					}
//				}
//			}
//		}
//		return true
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if let tweetVC = segue.destinationViewController as? TweetTableViewController where segue.identifier == Storyboard.segueFromkeyword {
			if let sender = sender as? UITableViewCell, let text = sender.textLabel?.text {
				tweetVC.searchText = text
				
				let popToRootButton = UIBarButtonItem(barButtonSystemItem: .Stop, target: self, action: Selector.popToRootViewController)
				tweetVC.addBarButton(popToRootButton, side: .Right, order: .Post)
			}
		}
		if segue.identifier == Storyboard.ShowImageSegue {
			if let ivc = segue.destinationViewController as? ImageViewController {
				if let cell = sender as? ImageTableViewCell {
					ivc.imageURL = cell.imageURL
					ivc.title = title
					
					let popToRootButton = UIBarButtonItem(barButtonSystemItem: .Stop, target: self, action: .popToRootViewController)
					ivc.addBarButton(popToRootButton, side: .Right, order: .Post)
				}
			}
		}
		if let webVC = segue.destinationViewController as? WebViewController where segue.identifier == Storyboard.ShowWebSegue {
			if let cell = sender as? UITableViewCell, let indexPath = tableView.indexPathForCell(cell) {
				if let urlString = cell.textLabel?.text, let url = NSURL(string: urlString) {
					if mentionSections[indexPath.section].type == "URLs" {
						webVC.URL = url
						webVC.title = cell.textLabel?.text
					}
				}
			}
		}
	}
	
	override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		switch mentionSections[indexPath.section].mentions[indexPath.row] {
		case .Image(_, let aspectRatio):
			return tableView.bounds.size.width / CGFloat(aspectRatio)
		case .Keyword(_):
			return UITableViewAutomaticDimension
		}
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		switch mentionSections[indexPath.section].mentions[indexPath.row] {
		case .Image(let url, _):
			let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.Image, forIndexPath: indexPath)
			if let cell = cell as? ImageTableViewCell {
				cell.imageURL = url
			}
			return cell
		case .Keyword(let keyword):
			let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.Keyword, forIndexPath: indexPath)
			cell.textLabel?.text = keyword
			return cell
		}
	}
	
}

extension UIViewController {
	
	enum Sides {
		case Left
		case Right
	}
	
	enum Order {
		case Pre
		case Post
	}
	
	func addBarButton(button: UIBarButtonItem, side: Sides, order: Order) {
			switch side {
			case .Left:
				if let buttons = navigationItem.leftBarButtonItems {
					navigationItem.leftBarButtonItems = (order == .Post ? [button] : [])  + buttons + (order == .Pre ? [button] : [])
				} else {
					navigationItem.leftBarButtonItem = button
				}
			case .Right:
				if let buttons = navigationItem.rightBarButtonItems {
					navigationItem.rightBarButtonItems = (order == .Post ? [button] : [])  + buttons + (order == .Pre ? [button] : [])
				} else {
					navigationItem.rightBarButtonItem = button
				}
			}
	}
}

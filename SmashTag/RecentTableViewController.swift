//
//  RecentTableViewController.swift
//  SmashTag
//
//  Created by Danil Denshin on 05.09.16.
//  Copyright © 2016 el2Nil. All rights reserved.
//

import UIKit
import CoreData

class RecentTableViewController: UITableViewController {
	
//	var managedObjectContext: NSManagedObjectContext? = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext
	var managedObjectContext: NSManagedObjectContext?
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		if managedObjectContext == nil {
			UIManagedDocument.useDocument { document in
				self.managedObjectContext = document.managedObjectContext
			}
		}
		tableView.reloadData()
	}
	
	private var recentSearches: [String] {
		return RecentSearches.searches
	}
	
	// MARK: - Table view data source
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return RecentSearches.searches.count
	}
	
	private struct Storyboard {
		static let RecentCell = "Recent"
		static let ShowSearchSegue = "Show Search"
		static let ShowMentionRating = "Show Mention Rating"
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.RecentCell, forIndexPath: indexPath)
		
		cell.textLabel?.text = RecentSearches.searches[indexPath.row]
		
		return cell
	}
	
	override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
		if editingStyle == .Delete {
			RecentSearches.removeAtIndex(indexPath.row)
			tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
		}
	}
	
	// MARK: - Navigation
	
	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if let identifier = segue.identifier where identifier == Storyboard.ShowSearchSegue {
			if let tweetVC = segue.destinationViewController as? TweetTableViewController, let cell = sender as? UITableViewCell {
				if var text = cell.textLabel?.text {
					if text.hasPrefix("@") { text += " OR from:" + text}
					tweetVC.searchText = text
					
					let popToRootButton = UIBarButtonItem(barButtonSystemItem: .Stop, target: self, action: .popToRootViewController)
					tweetVC.addBarButton(popToRootButton, side: .Right, order: .Post)
				}
			}
		}
		if let identifier = segue.identifier where identifier == Storyboard.ShowMentionRating {
			if let ratingVC = segue.destinationViewController as? RatingsTableViewController, let cell = sender as? UITableViewCell {
				if let text = cell.textLabel?.text {
					ratingVC.searchTerm = text
					ratingVC.managedObjectContext = managedObjectContext
					ratingVC.title = text
				}
			}
			
		}
	}
	
}

//
//  RatingsTableViewController.swift
//  SmashTag
//
//  Created by Danil Denshin on 11.09.16.
//  Copyright © 2016 el2Nil. All rights reserved.
//

import UIKit
import CoreData

class RatingsTableViewController: CoreDataTableViewController {
	
	
	var searchTerm: String? { didSet { updateUI() } }
	var managedObjectContext: NSManagedObjectContext? { didSet { updateUI() } }
	var term: SearchTerm?
	
	private func updateUI() {
		
		if let context = managedObjectContext where searchTerm?.characters.count > 0 {
			
			
			let termRequest = NSFetchRequest(entityName: "SearchTerm")
			termRequest.sortDescriptors = [NSSortDescriptor(key: "searchText", ascending: true)]
			termRequest.predicate = NSPredicate(format: "searchText = %@", searchTerm!)
			
			
			context.performBlockAndWait {
				self.term = (try? context.executeFetchRequest(termRequest))?.first as? SearchTerm
			}
			if term != nil {
				
				let request = NSFetchRequest(entityName: "Mention")
				request.predicate = NSPredicate(format: "%@ in searchTerms and count > 1", term!)
				request.sortDescriptors = [
					NSSortDescriptor(key: "section", ascending: true),
					NSSortDescriptor(key: "count", ascending: false),
					NSSortDescriptor(key: "mentionText", ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))
				]
				
				self.fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: "section", cacheName: nil)
				
			} else {
				self.fetchedResultsController = nil
			}
			
		}
	}
	
	private struct Constants {
		static let MentionCell = "Mention Cell"
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier(Constants.MentionCell, forIndexPath: indexPath)
		
		if let mention = fetchedResultsController?.objectAtIndexPath(indexPath) as? Mention {
			
			var mentionText: String?
			var tweetCount: String = ""
			mention.managedObjectContext?.performBlockAndWait {
				mentionText = mention.mentionText
				tweetCount = mention.count != nil ? String(mention.count!) : ""
			}
			cell.textLabel?.text = mentionText
			cell.detailTextLabel?.text = tweetCount
			
		}
		
		
		return cell
	}
	
	
}

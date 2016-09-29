//
//  Mention.swift
//  SmashTag
//
//  Created by Danil Denshin on 09.09.16.
//  Copyright © 2016 el2Nil. All rights reserved.
//

import Foundation
import CoreData
import Twitter


class Mention: NSManagedObject {
	
	class func mentionWithMensionText(mentionText: String,
	                                    inSection section: String,
										forSearchText searchText: String,
										forTweet tweet: Tweet,
										inManagedObjectContext context: NSManagedObjectContext) -> Mention? {
		
		if let mention = getMention(mentionText, section: section, context: context) {
		
			if let searchTerm = SearchTerm.searchTermWithText(searchText, inManagedObjectContext: context) {
				let searchTerms = mention.mutableSetValueForKey("searchTerms")
				searchTerms.addObject(searchTerm)
			}
			
			let tweets = mention.mutableSetValueForKey("tweets")
			tweets.addObject(tweet)
			
			mention.count = mention.tweets?.count
			
			return mention
			
		}
		
		
		return nil
		
	}
	
	private class func getMention(mentionText: String, section: String, context: NSManagedObjectContext) -> Mention? {
		
		let request = NSFetchRequest(entityName: "Mention")
		request.predicate = NSPredicate(format: "mentionText = %@", mentionText)
		
		if let mention = (try? context.executeFetchRequest(request))?.first as? Mention {
			return mention
		} else if let mention = NSEntityDescription.insertNewObjectForEntityForName("Mention", inManagedObjectContext: context) as? Mention {
			mention.mentionText = mentionText
			mention.section = section
			return mention
		}
		
		return nil
		
	}
	


}

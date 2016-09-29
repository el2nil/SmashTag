//
//  TwitterUser.swift
//  SmashTag
//
//  Created by Danil Denshin on 07.09.16.
//  Copyright © 2016 el2Nil. All rights reserved.
//

import Foundation
import CoreData
import Twitter


class TwitterUser: NSManagedObject {
	
	class func twitterUserWithTwitterInfo(twitterInfo: Twitter.User, inManagedObjectContext context: NSManagedObjectContext) -> TwitterUser? {
		
		let request = NSFetchRequest(entityName: "TwitterUser")
		request.predicate = NSPredicate(format: "screenName = %@", twitterInfo.screenName)
		if let twitterUser = (try? context.executeFetchRequest(request))?.first as? TwitterUser {
			return twitterUser
		} else if let twitterUser = NSEntityDescription.insertNewObjectForEntityForName("TwitterUser", inManagedObjectContext: context) as? TwitterUser {
			twitterUser.screenName = twitterInfo.screenName
			twitterUser.name = twitterInfo.name
			return twitterUser
		}
		return nil
	}
	
	class func updateTweetCount(twitterUser: TwitterUser) {
		twitterUser.tweetCount = twitterUser.tweets?.count
	}
}

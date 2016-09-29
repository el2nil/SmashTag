//
//  Tweet.swift
//  SmashTag
//
//  Created by Danil Denshin on 07.09.16.
//  Copyright © 2016 el2Nil. All rights reserved.
//

import Foundation
import CoreData
import Twitter

private struct Constants {
	static let TimeToRemoveOldTweets: NSTimeInterval = 60*60*24
}

class Tweet: NSManagedObject
{
	class func removeOldTweets(context: NSManagedObjectContext) {
		
		let request = NSFetchRequest(entityName: "Tweet")
		request.predicate = NSPredicate(format: "posted < %@", NSDate(timeIntervalSinceNow: -Constants.TimeToRemoveOldTweets))
		if let oldTweets = (try? context.executeFetchRequest(request)) as? [Tweet] {
			
			print("deleted tweets: \(oldTweets.count)")
			var mentionsToUpdate: [Mention] = []
			for tweet in oldTweets {
				let req = NSFetchRequest(entityName: "Mention")
				req.predicate = NSPredicate(format: "%@ in tweets", tweet)
				if let mentions = (try? context.executeFetchRequest(req)) as? [Mention] {
					mentionsToUpdate += mentions
				}
				context.deleteObject(tweet)
			}
			
			try! context.save()

			let setOfMentions = Set(mentionsToUpdate)
			print("deleted mentions: \(setOfMentions.count)")
			for mention in setOfMentions {
				mention.count = mention.tweets?.count ?? 0
				if mention.count == 0 {
					context.deleteObject(mention)
				}
			}
			
			try! context.save()
			
			let termRequest = NSFetchRequest(entityName: "SearchTerm")
			if let terms = (try? context.executeFetchRequest(termRequest)) as? [SearchTerm] {
				for term in terms {
					if term.mentions?.count == 0 {
						context.deleteObject(term)
					}
				}
			}
			try! context.save()
			
		}
		
	}
	
	class func newTweetsWithTwitterInfo(twitterInfo: [Twitter.Tweet], searchText: String, inManagedObjectContext context: NSManagedObjectContext) {
		
		var newTweetsIDs = Set(twitterInfo.map { $0.id })
		let request = NSFetchRequest(entityName: "Tweet")
		request.predicate = NSPredicate(format: "unique in %@", newTweetsIDs)
		
		if let tweets = (try? context.executeFetchRequest(request)) as? [Tweet] {
			
			let databaseIDs = tweets.flatMap { $0.unique }
			let databaseIDsSet = Set(databaseIDs)
			newTweetsIDs.subtractInPlace(databaseIDsSet)
			print("Новых в твитов в базе данных: \(newTweetsIDs.count)")
			
			for unique in newTweetsIDs {
				if let index = twitterInfo.indexOf({ $0.id == unique }) {
					
					if let tweet = NSEntityDescription.insertNewObjectForEntityForName("Tweet", inManagedObjectContext: context) as? Tweet {
						
						let tweetUser = TwitterUser.twitterUserWithTwitterInfo(twitterInfo[index].user, inManagedObjectContext: context)
						tweet.tweeter = tweetUser
						if tweetUser != nil {
							TwitterUser.updateTweetCount(tweetUser!)
						}
						
						tweet.unique = twitterInfo[index].id
						tweet.text = twitterInfo[index].text
						tweet.posted = twitterInfo[index].created
						
						for userMention in twitterInfo[index].userMentions {
							_ = Mention.mentionWithMensionText(userMention.keyword, inSection: "Users", forSearchText: searchText, forTweet: tweet, inManagedObjectContext: context)
						}
						for hashtag in twitterInfo[index].hashtags {
							_ = Mention.mentionWithMensionText(hashtag.keyword, inSection: "Hashtags", forSearchText: searchText, forTweet: tweet, inManagedObjectContext: context)
						}
					}
					
					
				}
			}
		}
		
		
		
	}
	class func tweetWithTwitterInfo(twitterInfo: Twitter.Tweet, searchText: String, inManagedObjectContext context: NSManagedObjectContext) -> Tweet? {
		
		let request = NSFetchRequest(entityName: "Tweet")
		
		request.predicate = NSPredicate(format: "unique = %@", twitterInfo.id)
		
		if let tweet = (try? context.executeFetchRequest(request))?.first as? Tweet {
			return tweet
		} else if let tweet = NSEntityDescription.insertNewObjectForEntityForName("Tweet", inManagedObjectContext: context) as? Tweet {
			let tweetUser = TwitterUser.twitterUserWithTwitterInfo(twitterInfo.user, inManagedObjectContext: context)
			tweet.tweeter = tweetUser
			if tweetUser != nil {
				TwitterUser.updateTweetCount(tweetUser!)
			}
			
			tweet.unique = twitterInfo.id
			tweet.text = twitterInfo.text
			tweet.posted = twitterInfo.created
			
			for userMention in twitterInfo.userMentions {
				_ = Mention.mentionWithMensionText(userMention.keyword, inSection: "Users", forSearchText: searchText, forTweet: tweet, inManagedObjectContext: context)
			}
			for hashtag in twitterInfo.hashtags {
				_ = Mention.mentionWithMensionText(hashtag.keyword, inSection: "Hashtags", forSearchText: searchText, forTweet: tweet, inManagedObjectContext: context)
			}
			
			return tweet
		}
		
		
		return nil
	}
	
}

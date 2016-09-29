//
//  TwitterUser+CoreDataProperties.swift
//  SmashTag
//
//  Created by Danil Denshin on 09.09.16.
//  Copyright © 2016 el2Nil. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension TwitterUser {

    @NSManaged var screenName: String?
    @NSManaged var name: String?
	@NSManaged var tweets: NSSet?
    @NSManaged var mensionCounters: NSSet?
	@NSManaged var tweetCount: NSNumber?

}

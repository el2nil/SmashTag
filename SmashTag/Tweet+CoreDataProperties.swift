//
//  Tweet+CoreDataProperties.swift
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

extension Tweet {

    @NSManaged var text: String?
    @NSManaged var unique: String?
    @NSManaged var posted: NSDate?
    @NSManaged var tweeter: TwitterUser?
    @NSManaged var mentions: NSSet?

}

//
//  Mention+CoreDataProperties.swift
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

extension Mention {

    @NSManaged var mentionText: String?
    @NSManaged var section: String?
    @NSManaged var count: NSNumber?
    @NSManaged var searchTerms: NSSet?
    @NSManaged var tweets: NSSet?

}

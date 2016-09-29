//
//  SearchTerm.swift
//  SmashTag
//
//  Created by Danil Denshin on 09.09.16.
//  Copyright © 2016 el2Nil. All rights reserved.
//

import Foundation
import CoreData


class SearchTerm: NSManagedObject {
	
	class func searchTermWithText(searchText: String, inManagedObjectContext contex: NSManagedObjectContext) -> SearchTerm? {
		
		let request = NSFetchRequest(entityName: "SearchTerm")
		request.predicate = NSPredicate(format: "searchText = %@", searchText)
		if let searchTerm = (try? contex.executeFetchRequest(request))?.first as? SearchTerm {
			return searchTerm
		} else if let seatchTerm = NSEntityDescription.insertNewObjectForEntityForName("SearchTerm", inManagedObjectContext: contex) as? SearchTerm {
			seatchTerm.searchText = searchText
			return seatchTerm			
		}
		
		return nil
	}

}

//
//  RecentSearches.swift
//  SmashTag
//
//  Created by Danil Denshin on 05.09.16.
//  Copyright © 2016 el2Nil. All rights reserved.
//

import Foundation

struct RecentSearches {
	
	private static let defaults = NSUserDefaults.standardUserDefaults()
	private static let limit = 100
	private static let key = "RecentSearches"
	
	static var searches: [String] {
		get {
			return defaults.objectForKey(key) as? [String] ?? []
		}
	}
	
	static func add(term: String) {
		var newArray = searches.filter { term.caseInsensitiveCompare($0) != .OrderedSame }
		newArray.insert(term, atIndex: 0)
		while newArray.count > limit {
			newArray.removeLast()
		}
		defaults.setObject(newArray, forKey: key)
	}
	
	static func removeAtIndex(index: Int) {
		var currentSearches = searches
		currentSearches.removeAtIndex(index)
		defaults.setObject(currentSearches, forKey: key)
	}
	
}
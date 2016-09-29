//
//  DataBase.swift
//  SmashTag
//
//  Created by Danil Denshin on 11.09.16.
//  Copyright © 2016 el2Nil. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class MyDocument: UIManagedDocument {
	
	override class func persistentStoreName() -> String {
		return "Twitter.sqlite"
	}
	
	override func contentsForType(typeName: String) throws -> AnyObject {
		print("__Auto-saving Document")
		return try! super.contentsForType(typeName)
	}
	
	override func handleError(error: NSError, userInteractionPermitted: Bool) {
		print("__Ошибка при записи: \(error.localizedDescription)")
		if let userInfo = error.userInfo as? [String:AnyObject] {
			if let conflicts = userInfo["conflictList"] as? NSArray {
				print("__Конфликты при записи: \(conflicts)")
			}
		}
	}
	
}

extension UIManagedDocument {
	
	class func useDocument(completion: (document: MyDocument) -> Void) {
		let fileManager = NSFileManager.defaultManager()
		let doc = "database"
		let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
		
		let url = urls.first!.URLByAppendingPathComponent(doc)
		print(url)
		let document = MyDocument(fileURL: url)
		
		document.persistentStoreOptions = [
			NSMigratePersistentStoresAutomaticallyOption: true,
			NSInferMappingModelAutomaticallyOption: true]
		
		document.managedObjectContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
		
		if let parentContext = document.managedObjectContext.parentContext {
			parentContext.performBlock {
				parentContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
			}
		}
		
		if !fileManager.fileExistsAtPath(url.path!) {
			document.saveToURL(url, forSaveOperation: .ForCreating) { success in
				if success {
					print("__Файл создан: ")
					completion(document: document)
				}
			}
		} else {
			if document.documentState == .Closed {
				document.openWithCompletionHandler { success in
					if success {
						print("__Файл открыт")
						completion(document: document)
					}
				}
			} else {
				completion(document: document)
			}
		}
	}
}
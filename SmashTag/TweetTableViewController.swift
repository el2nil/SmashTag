//
//  TweetTableViewController.swift
//  SamshTag
//
//  Created by Danil Denshin on 04.09.16.
//  Copyright © 2016 el2Nil. All rights reserved.
//

import UIKit
import Twitter
import CoreData

class TweetTableViewController: UITableViewController, UITextFieldDelegate {
	
	//	var managedObjectContext: NSManagedObjectContext? = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext
	var managedObjectContext: NSManagedObjectContext?
	
	var tweets = [Array<Twitter.Tweet>]() {
		didSet {
			tableView.reloadData()
		}
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		if managedObjectContext == nil {
			UIManagedDocument.useDocument { document in
				self.managedObjectContext = document.managedObjectContext
			}
		}
	}
	
	var searchText: String? {
		didSet {
			if let text = searchText where text != "" {
				tweets.removeAll()
				searchForTweets()
				title = searchText
				RecentSearches.add(text)
			}
			//			guard let text = searchText where searchText != "" else { return }
			
		}
	}
	
	private var twitterRequest: Twitter.Request? {
		if let query = searchText where !query.isEmpty {
			return Twitter.Request(search: query + " -filter:retweets", count: 100)
		} else {
			return nil
		}
	}
	
	private var lastTwitterRequest: Twitter.Request?
	
	private func searchForTweets() {
		if let request = twitterRequest {
			lastTwitterRequest = request
			request.fetchTweets() { [weak weakSelf = self] newTweets in
				dispatch_async(dispatch_get_main_queue()) {
					if weakSelf?.lastTwitterRequest == request {
						if !newTweets.isEmpty {
							weakSelf?.tweets.insert(newTweets, atIndex: 0)
							weakSelf?.updateDatabase(newTweets, searchText: self.searchText!)
							
						}
					}
					weakSelf?.refreshControl?.endRefreshing()
				}
			}
		} else {
			self.refreshControl?.endRefreshing()
		}
		
	}
	
	private func updateDatabase(newTweets: [Twitter.Tweet], searchText: String) {
		managedObjectContext?.performBlock {
			
			Tweet.newTweetsWithTwitterInfo(newTweets, searchText: searchText, inManagedObjectContext: self.managedObjectContext!)
			
			//			for twitterInfo in newTweets {
			//				// create a new, unique Tweet with that Twitter info
			//				_ = Tweet.tweetWithTwitterInfo(twitterInfo, searchText: searchText, inManagedObjectContext: self.managedObjectContext!)
			
			do {
				try self.managedObjectContext?.save()
			} catch let error {
				print("Core Date Error: \(error)")
			}
			//			}
		}
		printDatabaseStatistic()
		print("done printong database statistics")
	}
	
	private func  printDatabaseStatistic() {
		managedObjectContext?.performBlock {
			if let results = try? self.managedObjectContext!.executeFetchRequest(NSFetchRequest(entityName: "TwitterUser")) {
				print("\(results.count) twitter users in database")
			}
			// more efficient way to count
			let tweetCont = self.managedObjectContext!.countForFetchRequest(NSFetchRequest(entityName: "Tweet"), error: nil)
			print("\(tweetCont) Tweets")
			let mentionCount = self.managedObjectContext!.countForFetchRequest(NSFetchRequest(entityName: "Mention"), error: nil)
			print("\(mentionCount) Mentions")
			let termsCount = self.managedObjectContext!.countForFetchRequest(NSFetchRequest(entityName: "SearchTerm"), error: nil)
			print("\(termsCount) search terms")
			
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.estimatedRowHeight = tableView.rowHeight
		tableView.rowHeight = UITableViewAutomaticDimension
		addBarButton(UIBarButtonItem(barButtonSystemItem: .Camera, target: self, action: #selector(showImages)), side: .Right, order: .Pre)
	}
	
	func showImages() {
		performSegueWithIdentifier(StroryBoard.ShowImages, sender: self)
	}
	
	// MARK: - UIViewTableViewSource
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return tweets.count
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return tweets[section].count
	}
	
	private struct StroryBoard {
		static let TweetCellIdentifier = "Tweet"
		static let ShowDetailSegue = "Show Detail"
		static let ShowImages = "Show Images"
		static let TweetersMentioningSearchTerm = "TweetersMentioningSearchTerm"
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier(StroryBoard.TweetCellIdentifier, forIndexPath: indexPath)
		
		let tweet = tweets[indexPath.section][indexPath.row]
		if let tweetCell = cell as? TweetTableViewCell {
			tweetCell.tweet = tweet
		}
		
		return cell
	}
	
	@IBOutlet weak var searchTextField: UITextField! {
		didSet {
			searchTextField.delegate = self
			searchTextField.text = searchText
		}
	}
	
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		//		resignFirstResponder()
		view.endEditing(true)
		searchText = textField.text
		return true
	}
	
	@IBAction func refreshTweets(sender: UIRefreshControl) {
		searchForTweets()
	}
	
	// MARK: - Navigation
	
	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if let identifier = segue.identifier where identifier == StroryBoard.ShowDetailSegue {
			if let detailTVC = segue.destinationViewController as? TweetDetailTableViewController {
				if let indexPath = tableView.indexPathForSelectedRow {
					let tweet = tweets[indexPath.section][indexPath.row]
					detailTVC.tweet = tweet
					
					let popToRootButton = UIBarButtonItem(barButtonSystemItem: .Stop, target: self, action: Selector.popToRootViewController)
					detailTVC.addBarButton(popToRootButton, side: .Right, order: .Post)
				}
			}
		}
		if let identifier = segue.identifier where identifier == StroryBoard.ShowImages {
			if let imagesVC = segue.destinationViewController as? ImageCollectionViewController, let searchText = searchText {
				imagesVC.tweets = tweets
				imagesVC.title = "Images: \(searchText)"
				
				let popToRootButton = UIBarButtonItem(barButtonSystemItem: .Stop, target: self, action: Selector.popToRootViewController)
				imagesVC.addBarButton(popToRootButton, side: .Right, order: .Post)
			}
		}
		if segue.identifier ==  StroryBoard.TweetersMentioningSearchTerm {
			if let tweetersTV = segue.destinationViewController as? TweetersTableViewController {
				tweetersTV.mention = searchText
				tweetersTV.managedObjectContext = managedObjectContext
			}
		}
	}
	
}

extension Selector {
	static let popToRootViewController = #selector(UIViewController.popToRootViewController)
}

extension UIViewController {
	func popToRootViewController() {
		self.navigationController?.popToRootViewControllerAnimated(true)
	}
}

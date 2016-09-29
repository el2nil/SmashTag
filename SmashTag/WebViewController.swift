//
//  WebViewController.swift
//  SmashTag
//
//  Created by Danil Denshin on 05.09.16.
//  Copyright © 2016 el2Nil. All rights reserved.
//

import UIKit

class WebViewController: UIViewController, UIWebViewDelegate {
	
	@IBOutlet weak var webView: UIWebView!
	@IBOutlet weak var spinner: UIActivityIndicatorView!
	
	var URL: NSURL?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		webView.delegate = self
		if let url = URL {
//			webView.scalesPageToFit = true
			webView.loadRequest(NSURLRequest(URL: url))
			navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(closeWebVC))
			navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .Plain, target: self, action: #selector(navigateToPrevious))
		}
	}
	
	func closeWebVC() {
		navigationController?.popViewControllerAnimated(true)
	}
	
	func navigateToPrevious() {
		if webView.canGoBack {
			webView.goBack()
		}
		
	}
	
	func webViewDidStartLoad(webView: UIWebView) {
		UIApplication.sharedApplication().networkActivityIndicatorVisible = true
		spinner.startAnimating()
	}
	
	func webViewDidFinishLoad(webView: UIWebView) {
		UIApplication.sharedApplication().networkActivityIndicatorVisible = false
		spinner.stopAnimating()
	}
	
	func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
		UIApplication.sharedApplication().networkActivityIndicatorVisible = false
		spinner.stopAnimating()
		print("problems with loading web")
	}
	
}

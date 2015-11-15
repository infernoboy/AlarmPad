//
//  ViewController.swift
//  Alarm Pad
//
//  Created by Travis Roman on 11/13/15.
//  Copyright © 2015 Travis Roman. All rights reserved.
//

import UIKit

extension NSURLRequest {
	class func allowsAnyHTTPSCertificateForHost(host: String) -> Bool {
		return true;
	}
}

class ViewController: UIViewController {

	@IBOutlet weak var theWebView: UIWebView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		UIWebView.loadRequest(self.theWebView)(NSURLRequest(URL: NSURL(string: "https://lion.toggleable.com:161/alarm/")!));
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


}


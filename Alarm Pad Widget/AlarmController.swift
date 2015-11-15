//
//  AlarmController.swift
//  Alarm Pad
//
//  Created by Travis Roman on 11/15/15.
//  Copyright © 2015 Travis Roman. All rights reserved.
//

import UIKit
import Foundation
import Alamofire

extension NSURLRequest {
	class func allowsAnyHTTPSCertificateForHost(host: String) -> Bool {
		return true;
	}
}

public class AlarmController {
	let alarmBaseURL = "https://lion.toggleable.com:161/alarm/";
	
	var viewController: TodayViewController;
	
	init (viewController: TodayViewController) {
		self.viewController = viewController;
	}
	
	public func disarmWithPasscode(passcode: String) {
		NSLog("Attempting to disarm with passcode: \(passcode)");
			
		Alamofire
			.request(.POST, self.alarmBaseURL + "disarm.php", parameters: ["passcode": passcode])
			.responseString { response in
				self.viewController.showInfo(response.result.value!);
			}
		
	}
}
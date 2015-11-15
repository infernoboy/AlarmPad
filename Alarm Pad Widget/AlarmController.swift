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
	
	let knownCameras: [String:String] = [
		"5": "Living Room",
		"6": "Kitchen",
		"7": "Bedroom",
		"14": "Facetime",
		"13": "Intruder Detection",
		"15": "Siren Detection"
	]
	
	var viewController: TodayViewController;
	var fetchRemoteStatusTimeout: PreservedTimeout?;
	var armCountdownTimeout: PreservedTimeout?;
	
	var isArming = false;
	var armCountdownSeconds = 26;
	
	init (viewController: TodayViewController) {
		self.viewController = viewController;
		
		self.fetchRemoteStatusTimeout = PreservedTimeout(15) {
			self.fetchRemoteStatus();
		}
	}
	
	private func beginArmCountdown() {
		self.isArming = true;
		self.armCountdownSeconds = 26;
		
		if (self.armCountdownTimeout != nil) {
			self.armCountdownTimeout?.reset();
		} else {
			self.armCountdownTimeout = PreservedTimeout(1) {
				if (self.isArming) {
					self.armCountdownSeconds -= 1;
					
					self.viewController.updateStatus("ARMING IN \(self.armCountdownSeconds) SECONDS", isDisarmed: false);
					
					if (self.armCountdownSeconds > 0) {
						self.armCountdownTimeout?.reset();
					} else if (self.armCountdownSeconds == 0) {
						self.isArming = false;
						
						self.viewController.updateStatus("ARMED", isDisarmed: false);
					}
				} else {
					self.fetchRemoteStatus();
				}
			}
		}
	}
	
	public func fetchRemoteStatus() -> Void {
		if (!self.isArming) {
			Alamofire
				.request(.GET, self.alarmBaseURL + "status.php")
				.responseJSON { response in
					if (!self.isArming) {
						if (response.result.error != nil) {
								self.viewController.updateStatus("UNKNOWN", isDisarmed: true);
						} else {
							let status = response.result.value!
							
							if (status["intruder"] as! NSInteger == 1) {
								self.viewController.updateStatus("INTRUDER", isDisarmed: false);
							} else if (status["temporarilyDisarmed"] as! NSInteger == 1) {
								self.viewController.updateStatus("TEMPORARY DISARM", isDisarmed: true);
							} else if (status["armed"] as! NSInteger == 1) {
								self.viewController.updateStatus("ARMED", isDisarmed: false);
							} else {
								self.viewController.updateStatus("UNARMED", isDisarmed: true);
							}
						}
					}
				}
		}
		
		self.fetchRemoteStatusTimeout?.reset();
	}
	
	public func disarmWithPasscode(passcode: String) {
		self.fetchRemoteStatusTimeout?.reset();
		
		self.viewController.updateStatus("DISARMING...", isDisarmed: nil);
		
		Alamofire
			.request(.POST, self.alarmBaseURL + "disarm.php", parameters: ["passcode": passcode])
			.responseString { response in
				if (response.result.error != nil) {
					self.viewController.updateStatus("UNKNOWN", isDisarmed: true);
					self.viewController.showInfo("Error: \(response.result.error!)");
				} else {
					switch response.result.value! {
						case "2":
							self.isArming = false;
							
							self.viewController.updateStatus("UNARMED", isDisarmed: true);
						case "1":
							self.isArming = false;
							
							self.viewController.updateStatus("TEMPORARY DISARM", isDisarmed: true);
						default:
							self.fetchRemoteStatus();
							
							self.viewController.showInfo("Invalid passcode.");
					}
				}
			}
	}
	
	public func armWithPasscode(passcode: String) {
		self.fetchRemoteStatusTimeout?.reset();
		
		self.viewController.updateStatus("ARMING...", isDisarmed: nil);
		
		Alamofire
			.request(.POST, self.alarmBaseURL + "arm.php", parameters: ["passcode": passcode])
			.responseString { response in
				if (response.result.error != nil) {
					self.viewController.updateStatus("UNKNOWN", isDisarmed: true);
					self.viewController.showInfo("Error: \(response.result.error!)");
				} else {
					self.fetchRemoteStatus();
					
					var status: AnyObject?
					
					if (passcode == "0") {
						do {
							status = try NSJSONSerialization.JSONObjectWithData((response.result.value?.dataUsingEncoding(NSUTF8StringEncoding))!, options: NSJSONReadingOptions.AllowFragments);
							
							var cameraStatus: [String:String] = [:];
							
							for (cameraID, cameraName) in self.knownCameras {
								if (status?[cameraID] != nil) {
									cameraStatus[cameraName] = (status?[cameraID] as! Bool) ? "ACTIVE" : "passive";
								}
							}
							
							let jsonData = try NSJSONSerialization.dataWithJSONObject(cameraStatus, options: .PrettyPrinted);
							let jsonText = NSString(data: jsonData, encoding: NSUTF8StringEncoding);
								
							self.viewController.showInfo(jsonText as! String);
						} catch _ {}
					} else {
						switch response.result.value! {
							case "2":
								self.viewController.showInfo("Opened SecuritySpy.");
							case "1":
								self.beginArmCountdown();
							default:
								self.viewController.showInfo("Invalid passcode.");
						}
					}
				}
		}
	}
}
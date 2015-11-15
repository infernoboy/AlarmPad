//
//  TodayViewController.swift
//  Alarm Pad Widget
//
//  Created by Travis Roman on 11/13/15.
//  Copyright © 2015 Travis Roman. All rights reserved.
//

import UIKit
import NotificationCenter

extension CALayer {
	func borderUIColor() -> UIColor? {
		return borderColor != nil ? UIColor(CGColor: borderColor!) : nil
	}
	
	func setBorderUIColor(color: UIColor) {
		borderColor = color.CGColor
	}
}

class PadButton: UIButton {
	var padValue: String = "";
	
	override var highlighted: Bool {
		didSet {
			let isHighlighted = highlighted;
			let buttonLayer = self.layer;
			let whiteColor: UIColor = UIColor.whiteColor();
			
			UIView.animateWithDuration(0.25, animations: { () -> Void in
				if (isHighlighted) {
					buttonLayer.backgroundColor = whiteColor.colorWithAlphaComponent(0.3).CGColor;
				} else {
					buttonLayer.backgroundColor = whiteColor.colorWithAlphaComponent(0.11).CGColor;
				}
			});
		}
	}
}

class PreservedTimeout: NSObject
{
	private var timer: NSTimer?
	private var callback: (Void -> Void)?
	private var delaySeconds: Double? = 0;
	
	init(_ delaySeconds: Double = 0, _ callback: Void -> Void) {
		super.init()
		
		self.callback = callback
		self.delaySeconds = delaySeconds;
		
		self.createTimer();
	}
	
	private func createTimer() {
		self.timer?.invalidate();
		
		self.timer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(self.delaySeconds!),
			target: self,
			selector: "invoke",
			userInfo: nil,
			repeats: false
		)
	}
	
	func setDelay(delaySeconds: Double) -> PreservedTimeout {
		self.delaySeconds = delaySeconds;
		
		return self;
	}
	
	func reset() -> PreservedTimeout {
		self.createTimer();
		
		return self;
	}
	
	func invoke() {
		self.callback?();
		
		self.timer = nil
	}
	
	func cancel() {
		self.timer?.invalidate()
		self.timer = nil
	}
}

class TodayViewController: UIViewController, NCWidgetProviding {
	@IBOutlet weak var toggleButton: UIButton!
	@IBOutlet weak var alarmStatus: UILabel!
	@IBOutlet weak var passcodeInput: UILabel!
	@IBOutlet weak var disarmButton: UIButton!
	@IBOutlet weak var mainView: UIStackView!
	@IBOutlet var infoView: UIView!
	@IBOutlet weak var infoText: UITextView!
	
	@IBOutlet weak var armButton: UIButton!

	var isCollapsed = false;
	var passcode = "";
	
	var emptyPasscodeTimeout: PreservedTimeout? = nil;
	
	let defaults = NSUserDefaults.standardUserDefaults();
	
	let expandedHeight = CGFloat(297);
	let collapsedHeight = CGFloat(38);
	let width = CGFloat(320);
	
	func widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
		return UIEdgeInsetsZero;
	}

	override func viewDidLoad() {
		super.viewDidLoad();
		
		if (defaults.boolForKey("isCollapsed")) {
			self.isCollapsed = true;
			
			self.collapse();
		} else {
			self.expand();
		}
		
		self.emptyPasscodeTimeout = PreservedTimeout(0) {
			self.updatePasscode("");
			
			self.emptyPasscodeTimeout?.setDelay(2.0);
		}
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
			// Dispose of any resources that can be recreated.
	}
	
	func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
			// Perform any setup necessary in order to update the view.

			// If an error is encountered, use NCUpdateResult.Failed
			// If there's no update required, use NCUpdateResult.NoData
			// If there's an update, use NCUpdateResult.NewData

		completionHandler(NCUpdateResult.NewData)
	}
	
	func collapse() {
		self.preferredContentSize = CGSizeMake(self.width, self.collapsedHeight);
		
		self.toggleButton.setTitle("▷", forState: .Normal);
	}
	
	func expand() {
		self.preferredContentSize = CGSizeMake(self.width, self.expandedHeight);
		
		self.toggleButton.setTitle("▽", forState: .Normal);
	}
	
	func updatePasscode(passcode: String) {
		self.passcode = passcode;
		
		if (self.passcode.characters.count > 0) {
			self.passcodeInput.text = String(count: self.passcode.characters.count, repeatedValue: Character("•"));
			
			self.passcodeInput.textColor = UIColor.whiteColor();
		}	else {
			self.passcodeInput.text = String(count: 8, repeatedValue: Character("◦"));
			
			self.passcodeInput.textColor = UIColor.whiteColor().colorWithAlphaComponent(0.1);
		}
	}
	
	func updateStatus(status: String, isDisarmed: Bool?) {
		self.alarmStatus.text = status;
		
		if (isDisarmed != nil) {
			self.alarmStatus.textColor = isDisarmed == true ? self.disarmButton.titleColorForState(.Normal) : self.armButton.titleColorForState(.Normal);
		}
	}
	
	@IBAction func toggleMainView(sender: AnyObject) {
		UIView.animateWithDuration(0.25, delay: 0, options: .CurveEaseOut, animations: { () -> Void in
			self.isCollapsed ? self.expand() : self.collapse();
		}, completion: nil);
		
		self.isCollapsed = !self.isCollapsed;
		
		self.defaults.setBool(self.isCollapsed, forKey: "isCollapsed");
	}
	
	@IBAction func padNumberPressed(sender: AnyObject) {
		if (self.passcode.characters.count < 8) {
			let padValue = sender.valueForKeyPath("padValue") as! String
			
			self.updatePasscode("\(self.passcode)\(padValue)");
		}
		
		self.emptyPasscodeTimeout?.reset();
	}
	
	@IBAction func passcodeDelete(sender: AnyObject) {
		let currentValue = self.passcode as NSString;
		
		if (currentValue.length > 0) {
			self.updatePasscode(currentValue.substringWithRange(NSRange(location: 0, length: currentValue.length - 1)));
		}
	}
	
	@IBAction func performDisarm(sender: AnyObject) {
		if (self.passcode.characters.count > 0) {
			self.updatePasscode("");
			self.updateStatus("DISARMING...", isDisarmed: nil);
			
			_ = PreservedTimeout(2.0) {
				self.updateStatus("DISARMED", isDisarmed: true);
			}
		}
	}
	
	@IBAction func performArm(sender: AnyObject) {
		if (self.passcode.characters.count > 0) {
			self.updatePasscode("");
			self.updateStatus("ARMING...", isDisarmed: nil);
			
			_ = PreservedTimeout(2.0) {
				self.updateStatus("ARMED", isDisarmed: false);
			}
		}
		
		self.showInfo("@IBAction func dismissInfoView(sender: AnyObject) {\nsdfdsfds\nsdfsdfsdf\nsdfsdf\nsdfsdfd\nsdfsddf\nsdfsd");
	}
	
	func showInfo(info: String) {
		self.infoText.text = info;
		
		UIView.animateWithDuration(0.25, delay: 0, options: .CurveEaseOut, animations: { () -> Void in
			self.infoView.hidden = false;
			self.infoView.alpha = 1;
		}, completion: nil);
	}
	
	@IBAction func dismissInfoView(sender: AnyObject) {
		UIView.animateWithDuration(0.25, delay: 0, options: .CurveEaseOut, animations: { () -> Void in
			self.infoView.hidden = false;
			self.infoView.alpha = 0;
		}, completion: { finished in
			self.infoView.hidden = true;
		});
	}
}

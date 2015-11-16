//
//  Utilities.swift
//  Alarm Pad
//
//  Created by Travis Roman on 11/15/15.
//  Copyright © 2015 Travis Roman. All rights reserved.
//

import UIKit
import Foundation

extension UIView {
	func slideInFromBottom(duration: NSTimeInterval = 1.0, completionDelegate: AnyObject? = nil) {
		let slideInFromBottom = CATransition()
		
		if let delegate: AnyObject = completionDelegate {
			slideInFromBottom.delegate = delegate;
		}
		
		slideInFromBottom.type = kCATransitionPush;
		slideInFromBottom.subtype = kCATransitionFromTop;
		slideInFromBottom.duration = duration;
		slideInFromBottom.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut);
		slideInFromBottom.fillMode = kCAFillModeRemoved;
		
		self.layer.addAnimation(slideInFromBottom, forKey: "slideInFromBottomTransition")
	}
	
	func slideOutFromBottom(duration: NSTimeInterval = 1.0, completionDelegate: AnyObject? = nil) {
		let slideOutFromBottom = CATransition()
				
		if let delegate: AnyObject = completionDelegate {
			slideOutFromBottom.delegate = delegate;
		}
		
		slideOutFromBottom.type = kCATransition;
		slideOutFromBottom.subtype = kCATransitionFromTop;
		slideOutFromBottom.duration = duration;
		slideOutFromBottom.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut);
		slideOutFromBottom.fillMode = kCAFillModeRemoved;
		
		self.layer.addAnimation(slideOutFromBottom, forKey: "slideOutFromBottomTransition")
	}
}

extension String {
	var localized: String {
		return NSLocalizedString(self, tableName: nil, bundle: NSBundle.mainBundle(), value: "", comment: "");
	}
	
	func localizeWithData(data: String) -> String {
		return String.localizedStringWithFormat(NSLocalizedString(self, tableName: nil, bundle: NSBundle.mainBundle(), value: "", comment: ""), data);
	}
}

extension CALayer {
	func borderUIColor() -> UIColor? {
		return borderColor != nil ? UIColor(CGColor: borderColor!) : nil
	}
	
	func setBorderUIColor(color: UIColor) {
		borderColor = color.CGColor
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
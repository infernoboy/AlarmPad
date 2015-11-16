//
//  Localizable.swift
//  Alarm Pad
//
//  Created by Travis Roman on 11/16/15.
//  Copyright © 2015 Travis Roman. All rights reserved.
//

import UIKit
import Foundation

class LocalizableUILabel: UILabel {
	override func awakeFromNib() {
		if let text = text {
			self.text = text.localized;
		}
	}
}

class LocalizableUIButton: UIButton {
	override func awakeFromNib() {
		for state in [UIControlState.Normal, UIControlState.Highlighted, UIControlState.Selected, UIControlState.Disabled] {
			if let title = titleForState(state) {
				setTitle(title.localized, forState: state);
			}
		}
	}
}
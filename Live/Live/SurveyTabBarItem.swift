//
//  SurveyTabBarItem.swift
//  Live
//
//  Created by Denis Bohm on 1/3/17.
//  Copyright © 2017 Firefly Design LLC. All rights reserved.
//

import UIKit

class SurveyTabBarItem: UITabBarItem {

    @IBInspectable var hiliteFont: UIFont = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.bold)
    @IBInspectable var hiliteColor: UIColor = UIColor.red

    var hiliteState: Bool = false
    var hilite: Bool {
        get {
            return hiliteState
        }
        set {
            if newValue {
                setTitleTextAttributes([NSAttributedStringKey.font: hiliteFont, NSAttributedStringKey.foregroundColor: hiliteColor], for: UIControlState.normal)
            } else {
                setTitleTextAttributes([:], for: UIControlState.normal)
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

}

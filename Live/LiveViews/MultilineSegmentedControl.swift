//
//  MultilineSegmentedControl.swift
//  LiveViews
//
//  Created by Denis Bohm on 2/5/18.
//  Copyright © 2018 Firefly Design LLC. All rights reserved.
//

import UIKit

open class MultilineSegmentedControl: UISegmentedControl {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setDefaults()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setDefaults()
    }

    public func setDefaults() {
        for segment in subviews {
            for subview in segment.subviews {
                if let label = subview as? UILabel {
                    label.textAlignment = .center
                    label.lineBreakMode = .byWordWrapping
                    label.numberOfLines = 0
                }
            }
        }
    }
    
}

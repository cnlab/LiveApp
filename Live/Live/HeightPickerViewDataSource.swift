//
//  HeightPickerViewDataSource.swift
//  Live
//
//  Created by Denis Bohm on 1/2/17.
//  Copyright © 2017 Firefly Design LLC. All rights reserved.
//

import UIKit

class HeightPickerViewDataSource: PickerViewDataSource {

    let feet: [Int?]
    let inches: [Int?]

    static func newComponent(range: ClosedRange<Int>) -> [Int?] {
        var component: [Int?] = [nil]
        for value in range.lowerBound ... range.upperBound {
            component.append(value)
        }
        return component
    }

    init() {
        self.feet = HeightPickerViewDataSource.newComponent(range: 0...9)
        self.inches = HeightPickerViewDataSource.newComponent(range: 0...11)

        super.init(components: [feet, inches], suffixes: ["'", "\""])
    }

    override func index(of value: Any?, forComponent component: Int) -> Int? {
        if let values = components[component] as? [Int?], let value = value as? Int? {
            let index = values.index { ($0 as Int?) == value }
            if let index = index {
                return index
            }
        }
        return nil
    }
    
}

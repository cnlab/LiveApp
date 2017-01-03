//
//  StringArrayPickerViewDataSource.swift
//  Live
//
//  Created by Denis Bohm on 12/29/16.
//  Copyright © 2016 Firefly Design LLC. All rights reserved.
//

import UIKit

class StringArrayPickerViewDataSource: PickerViewDataSource {

    init(values: [String]) {
        super.init(components: [values], suffixes: [""])
    }

    override func index(of value: Any?, forComponent component: Int) -> Int? {
        if let values = components[component] as? [String?], let value = value as? String? {
            let index = values.index { ($0 as String?) == value }
            if let index = index {
                return index
            }
        }
        return nil
    }

}

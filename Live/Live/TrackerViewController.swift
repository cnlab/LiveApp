//
//  TrackerViewController.swift
//  Live
//
//  Created by Denis Bohm on 10/31/17.
//  Copyright © 2017 Firefly Design LLC. All rights reserved.
//

import UIKit

class TrackerViewController: UIViewController {
    
    var name: String?
    
    func nameFromClass() -> String {
        var value = NSStringFromClass(type(of: self))
        let prefix = "Live."
        if value.hasPrefix(prefix) {
            value = String(value.dropFirst(prefix.count))
        }
        let suffix = "ViewController"
        if value.hasSuffix(suffix) {
            value = String(value.dropLast(suffix.count))
        }
        return value
    }
    
    func record(_ transition: Tracker.View.Transition) {
        let name = nameFromClass()
        Tracker.sharedInstance().record(name: name, transition: transition)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        record(.willAppear)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        record(.willDisappear)
    }

}

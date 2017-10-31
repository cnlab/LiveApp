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
        let value = NSStringFromClass(type(of: self))
        let suffix = "ViewController"
        if value.hasSuffix(suffix) {
            return String(value.dropLast(suffix.count))
        }
        return value
    }
    
    func track(_ transition: Tracker.View.Transition) {
        let name = self.name ?? NSStringFromClass(type(of: self))
        Tracker.sharedInstance().view(name: name, transition: transition)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        track(.willAppear)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        track(.willDisappear)
    }

}

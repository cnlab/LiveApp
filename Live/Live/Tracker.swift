//
//  Tracker.swift
//  Live
//
//  Created by Denis Bohm on 10/31/17.
//  Copyright © 2017 Firefly Design LLC. All rights reserved.
//

import UIKit

class Tracker {
    
    static let instance = Tracker()
    
    static func sharedInstance() -> Tracker {
        return instance
    }
    
    class Session {
        enum Transition {
            case didFinishLaunching
            case didBecomeActive
            case willResignActive
            case willEnterForeground
            case didEnterBackground
            case willTerminate
        }
    }
    
    class View {
        enum Transition {
            case willAppear
            case willDisappear
        }
    }
    
    func session(transition: Session.Transition) {
        NSLog("Tracker: session: transition: \(transition)")
    }
    
    func view(name: String, transition: View.Transition) {
        NSLog("Tracker: view: name: \(name) transition: \(transition)")
    }
    
    func action(category: String, name: String) {
        NSLog("Tracker: action: category: \(category) name: \(action)")
    }
    
    func event(category: String, name: String, value: String) {
        NSLog("Tracker: event: category: \(category) name: \(name) value: \(value)")
    }
    
    func variable(category: String, name: String, value: String) {
        NSLog("Tracker: variable: category: \(category) name: \(name) value: \(value)")
    }
    
}

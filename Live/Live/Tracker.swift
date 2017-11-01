//
//  Tracker.swift
//  Live
//
//  Created by Denis Bohm on 10/31/17.
//  Copyright © 2017 Firefly Design LLC. All rights reserved.
//

import UIKit

protocol TrackerDelegate {
    
    func tracker(_ tracker: Tracker, action: Tracker.Action)
    
}

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
    
    class Action: JSONConvertable {
        
        let category: String
        let name: String
        let date: String
        let value: String
        
        init(category: String, name: String, date: String, value: String) {
            self.category = category
            self.name = name
            self.date = date
            self.value = value
        }
        
        required init(json: [String: Any]) throws {
            let category = try JSON.jsonString(json: json, key: "category")
            let name = try JSON.jsonString(json: json, key: "name")
            let date = try JSON.jsonString(json: json, key: "date")
            let value = try JSON.jsonString(json: json, key: "value")
            
            self.category = category
            self.name = name
            self.date = date
            self.value = value
        }
        
        func json() -> [String: Any] {
            return [
                "category": JSON.json(string: category),
                "name": JSON.json(string: name),
                "date": JSON.json(string: date),
                "value": JSON.json(string: value),
            ]
        }
        
    }
    
    var delegate: TrackerDelegate?
    
    func record(category: String, name: String, value: String = "") {
        let now = Date()
        let date = DateFormatter.localizedString(from: now, dateStyle: .short, timeStyle: .medium)
        let action = Action(category: category, name: name, date: date, value: value)
        NSLog("Tracker Action: category: \(action.category) name: \(action.name) date: \(action.date) value: \(action.value)")
        delegate?.tracker(self, action: action)
    }
    
    func record(transition: Session.Transition) {
        record(category: "app", name: "session", value: String(describing: transition))
    }
    
    func record(name: String, transition: View.Transition) {
        record(category: "screen", name: name, value: String(describing: transition))
    }
    
}

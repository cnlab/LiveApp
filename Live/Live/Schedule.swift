//
//  Schedule.swift
//  Live
//
//  Created by Denis Bohm on 10/13/16.
//  Copyright © 2016 Firefly Design LLC. All rights reserved.
//

import Foundation

class Schedule: JSONConvertable {

    class Day: JSONConvertable {

        let moment: Moment
        let notes: [Note]

        init(moment: Moment, notes: [Note]) {
            self.moment = moment
            self.notes = notes
        }

        required init(json: [String: Any]) throws {
            let momentString = try JSON.jsonString(json: json, key: "date")
            let moment = try Moment.parse(string: momentString)
            let notes: [Note] = try JSON.jsonArray(json: json, key: "notes")

            self.moment = moment
            self.notes = notes
        }

        func json() -> [String: Any] {
            return [
                "date": JSON.json(string: Moment.format(moment: moment)),
                "notes": JSON.json(array: notes),
            ]
        }
        
        var isPending: Bool {
            get {
                return notes.reduce(false) { $0 || $1.isPending }
            }
        }

    }

    let days: [Day]

    init(days: [Day]) {
        self.days = days
    }

    required init(json: [String: Any]) throws {
        let days: [Day] = try JSON.jsonArray(json: json, key: "days")

        self.days = days
    }

    func json() -> [String: Any] {
        return [
            "days": JSON.json(array: days),
        ]
    }

    var isPending: Bool {
        get {
            return days.reduce(false) { $0 || $1.isPending }
        }
    }

    func pendingDays() -> [Day] {
        return days.filter() { $0.isPending }
    }

    func completedDays() -> [Day] {
        return days.filter() { !$0.isPending }
    }

}

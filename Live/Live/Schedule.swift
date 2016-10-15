//
//  Schedule.swift
//  Live
//
//  Created by Denis Bohm on 10/13/16.
//  Copyright © 2016 Firefly Design LLC. All rights reserved.
//

import Foundation

class Schedule : NSObject, NSCoding {

    class Day : NSObject, NSCoding {

        let date: Date
        let notes: [Note]

        init(date: Date, notes: [Note]) {
            self.date = date
            self.notes = notes
        }

        required convenience init?(coder decoder: NSCoder) {
            guard
                let date = decoder.decodeObject(forKey: "date") as? Date,
                let notes = decoder.decodeObject(forKey: "notes") as? [Note]
                else {
                    return nil
            }

            self.init(date: date, notes: notes)
        }

        func encode(with encoder: NSCoder) {
            encoder.encode(date, forKey: "date")
            encoder.encode(notes, forKey: "notes")
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

    required convenience init?(coder decoder: NSCoder) {
        guard
            let days = decoder.decodeObject(forKey: "days") as? [Day]
            else {
                return nil
        }

        self.init(days: days)
    }

    func encode(with encoder: NSCoder) {
        encoder.encode(days, forKey: "days")
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

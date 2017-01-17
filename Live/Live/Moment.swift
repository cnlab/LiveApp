//
//  Moment.swift
//  Live
//
//  Created by Denis Bohm on 1/16/17.
//  Copyright © 2017 Firefly Design LLC. All rights reserved.
//

import Foundation

class Moment {

    let year: Int
    let month: Int
    let day: Int

    init(year: Int, month: Int, day: Int) {
        self.year = year
        self.month = month
        self.day = day
    }

    static func parse(string: String) throws -> Moment {
        let tokens = string.components(separatedBy: "-")
        if tokens.count != 3 {
            throw JSON.SerializationError.invalid(string)
        }
        guard let year = Int(tokens[0]), let month = Int(tokens[1]), let day = Int(tokens[2]) else {
            throw JSON.SerializationError.invalid(string)
        }
        return Moment(year: year, month: month, day: day)
    }

    static func format(moment: Moment) -> String {
        return String(format: "%04d-%02d-%02d", moment.year, moment.month, moment.day)
    }

}

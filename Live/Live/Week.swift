//
//  Week.swift
//  Live
//
//  Created by Denis Bohm on 10/10/16.
//  Copyright © 2016 Firefly Design LLC. All rights reserved.
//

import Foundation

class Week {

    static func last() -> (startDate: Date, endDate: Date) {
        let now = Date()
        let calendar = Calendar.current
        var anchorComponents = (calendar as NSCalendar).components([.day, .month, .year], from: now)
        anchorComponents.hour = 0
        let anchorDate = calendar.date(from: anchorComponents)!

        var oneDayOffsetComponents = DateComponents()
        oneDayOffsetComponents.day = 1
        let endDate = (calendar as NSCalendar).date(byAdding: oneDayOffsetComponents, to: anchorDate, options: [])!
        var oneWeekOffsetComponents = DateComponents()
        oneWeekOffsetComponents.day = -7
        let startDate = (calendar as NSCalendar).date(byAdding: oneWeekOffsetComponents, to: endDate, options: [])!

        return (startDate: startDate, endDate: endDate)
    }

}

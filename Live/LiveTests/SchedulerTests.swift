//
//  SchedulerTests.swift
//  Live
//
//  Created by Denis Bohm on 1/15/17.
//  Copyright © 2017 Firefly Design LLC. All rights reserved.
//

import XCTest
@testable import Live

class SchedulerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func date(from string: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter.date(from: string)!
    }

    func newScheduler(for string: String) -> Scheduler {
        let activityMessageManager = ActivityMessageManager()
        let valueMessageManager = ValueMessageManager()
        let messageManagers: [MessageManager] = [valueMessageManager, activityMessageManager]
        let now = date(from: string)
        let trigger = DateComponents(hour: 9, minute: 0)
        let triggerOffsets: [String: TimeInterval] = ["Activity": 0, "Value": 10]
        let horizon = 1
        let scheduler = Scheduler(messageManagers: messageManagers, now: now, trigger: trigger, triggerOffsets: triggerOffsets, horizon: horizon)
        return scheduler
    }

    func testInitialNotes() {
        var scheduler = newScheduler(for: "1969-07-20 20:17:40")
        let days = scheduler.extendDays(previousDays: [])
        XCTAssert(days.count == 2)
        let sameDays = scheduler.extendDays(previousDays: days)
        XCTAssert(sameDays.count == 2)
        scheduler = newScheduler(for: "1969-07-21 17:54:00")
        let moreDays = scheduler.extendDays(previousDays: days)
        XCTAssert(moreDays.count == 3)
        let otherDays = scheduler.rescheduleDays(previousDays: moreDays)
        XCTAssert(otherDays.count == 3)
    }

}

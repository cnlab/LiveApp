//
//  ScheduleCoderTests.swift
//  Live
//
//  Created by Denis Bohm on 10/15/16.
//  Copyright © 2016 Firefly Design LLC. All rights reserved.
//

import XCTest
@testable import Live

class ScheduleCoderTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func encodeAndDecode<T>(_ object: T) -> T {
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWith: data)
        archiver.encode(object, forKey: "object")
        archiver.finishEncoding()
        let unarchiver = NSKeyedUnarchiver(forReadingWith: data as Data)
        return unarchiver.decodeObject(forKey: "object") as! T
    }

    func testNoteCoder() {
        let note = Schedule.Note(uuid: "uuid", type: "type", messageKey: Message.Key(group: "group", identifier: "identifier"), status: .pending)
        let unarchivedNote = encodeAndDecode(note)
        XCTAssertEqual(note.uuid, unarchivedNote.uuid)
    }

    func testDayCoder() {
        let note = Schedule.Note(uuid: "uuid", type: "type", messageKey: Message.Key(group: "group", identifier: "identifier"), status: .pending)
        let day = Schedule.Day(date: Date(), notes: [note])
        let unarchivedDay = encodeAndDecode(day)
        XCTAssertEqual(day.date, unarchivedDay.date)
        XCTAssertEqual(day.notes.count, unarchivedDay.notes.count)
    }

    func testScheduleCoder() {
        let note = Schedule.Note(uuid: "uuid", type: "type", messageKey: Message.Key(group: "group", identifier: "identifier"), status: .pending)
        let day = Schedule.Day(date: Date(), notes: [note])
        let schedule = Schedule(days: [day])
        let unarchivedSchedule = encodeAndDecode(schedule)
        XCTAssertEqual(schedule.days.count, unarchivedSchedule.days.count)
    }

}

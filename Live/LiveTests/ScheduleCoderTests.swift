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

    func encodeAndDecode<T>(_ object: T) throws -> T where T: JSONConvertable {
        let data = object.json()
        return try T(json: data)
    }

    func testNoteCoder() throws {
        let note = Note(uuid: "uuid", type: "type", messageKey: Message.Key(group: "group", identifier: "identifier"), status: .pending, date: Date())
        let unarchivedNote = try encodeAndDecode(note)
        XCTAssertEqual(note.uuid, unarchivedNote.uuid)
    }

    func testDayCoder() throws {
        let note = Note(uuid: "uuid", type: "type", messageKey: Message.Key(group: "group", identifier: "identifier"), status: .pending, date: Date())
        let day = Schedule.Day(moment: Moment(year: 2017, month: 1, day: 16), notes: [note])
        let unarchivedDay = try encodeAndDecode(day)
        XCTAssertEqual(day.moment.year, unarchivedDay.moment.year)
        XCTAssertEqual(day.moment.month, unarchivedDay.moment.month)
        XCTAssertEqual(day.moment.day, unarchivedDay.moment.day)
        XCTAssertEqual(day.notes.count, unarchivedDay.notes.count)
    }

    func testScheduleCoder() throws {
        let note = Note(uuid: "uuid", type: "type", messageKey: Message.Key(group: "group", identifier: "identifier"), status: .pending, date: Date())
        let day = Schedule.Day(moment: Moment(year: 2017, month: 1, day: 16), notes: [note])
        let schedule = Schedule(days: [day])
        let unarchivedSchedule = try encodeAndDecode(schedule)
        XCTAssertEqual(schedule.days.count, unarchivedSchedule.days.count)
    }

}

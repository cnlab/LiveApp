//
//  MessageManagerTests.swift
//  Live
//
//  Created by Denis Bohm on 9/21/16.
//  Copyright © 2016 Firefly Design LLC. All rights reserved.
//

import XCTest
@testable import Live

class MessageManagerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testItemPairFrequencyTable() {
        let manager = MessageManager()
        let table = manager.getItemPairFrequencyTable(groups: [20, 24, 30])
        let expected = [[0, 7, 13], [7, 0, 17], [13, 17, 0]]
        for i in 0 ..< 3 {
            for j in 0 ..< 3 {
                XCTAssertEqual(table[i][j], expected[i][j])
            }
        }
    }

    func testSequence() {
        let manager = HealthMessageManager()
        var identifiers = Set<String>(manager.messages.map { return $0.group + "." + $0.identifier })
        for _ in 0 ..< manager.messages.count {
            let message = manager.next()
            let identifier = message.group + "." + message.identifier
            identifiers.remove(identifier)
        }
        XCTAssert(identifiers.isEmpty)
    }

    func testFormat() {
        let manager = HealthMessageManager()
        for message in manager.messages {
            let parts = Set<String>(message.string.components(separatedBy: "/").filter { $0 != "" })
            for variant in message.variants.values {
                for key in variant.keys {
                    XCTAssert(parts.contains(key))
                }
            }

            let active = MessageManager.format(message: message)
            if message.variants.isEmpty {
                XCTAssertEqual(active, message.string)
            } else {
                XCTAssertEqual(active, message.string.replacingOccurrences(of: "/", with: ""))
                let inactive = MessageManager.format(message: message, variant: "inactive")
                XCTAssertNotEqual(active, inactive)
            }
        }
    }

}

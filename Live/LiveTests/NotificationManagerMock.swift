//
//  NotificationManagerMock.swift
//  LiveTests
//
//  Created by Denis Bohm on 9/26/17.
//  Copyright © 2017 Firefly Design LLC. All rights reserved.
//

import XCTest
@testable import Live

class NotificationManagerMock: MockObject, NotificationManager {
    
    var delegate: NotificationManagerDelegate?
    var authorized: Observable<Bool>
    
    override init() {
        delegate = nil
        authorized = Observable<Bool>(value: false)
    }
    
    let queryAuthorizationMockFunction = MockFunction(name: "queryAuthorization")
    
    func queryAuthorization() {
        remember(call: MockCall(function: queryAuthorizationMockFunction))
    }
    
    let authorizeMockFunction = MockFunction(name: "authorize")
    
    func authorize() {
        remember(call: MockCall(function: authorizeMockFunction))
    }
    
    let cancelMockFunction = MockFunction(name: "cancel")
    
    func cancel() {
        remember(call: MockCall(function: cancelMockFunction))
    }
    
    let requestMockFunction = MockFunction(name: "request", argumentMatchers: [
        "date": { (a, b) -> Bool in return MockObject.isEqualAs(type: Date.self, a: a, b: b) },
        "uuid": { (a, b) -> Bool in return MockObject.isEqualAs(type: String.self, a: a, b: b) },
        "type": { (a, b) -> Bool in return MockObject.isEqualAs(type: String.self, a: a, b: b) },
        "message": { (a, b) -> Bool in return MockObject.isEqualAs(type: Message.self, a: a, b: b) },
        ]
    )

    func request(date: Date, uuid: String, type: String, message: Message) {
        remember(call: MockCall(function: requestMockFunction))
    }
    
    let getOutstandingMockFunction = MockFunction(name: "getOutstanding")
    
    func getOutstanding() {
        remember(call: MockCall(function: getOutstandingMockFunction))
    }
    
    let nothingPendingMockFunction = MockFunction(name: "nothingPending")
    
    func nothingPending() {
        remember(call: MockCall(function: nothingPendingMockFunction))
    }
    
}

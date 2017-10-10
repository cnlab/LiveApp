//
//  Mock.swift
//  LiveTests
//
//  Created by Denis Bohm on 9/26/17.
//  Copyright © 2017 Firefly Design LLC. All rights reserved.
//

import Foundation

class MockFunction {
    
    let name: String
    let argumentMatchers: [String: (Any, Any) -> Bool]
    let resultMatcher: (Any, Any) -> Bool
    
    init(name: String, argumentMatchers: [String: (Any, Any) -> Bool], resultMatcher: @escaping (Any, Any) -> Bool) {
        self.name = name
        self.argumentMatchers = argumentMatchers
        self.resultMatcher = resultMatcher
    }
    
    init(name: String, argumentMatchers: [String: (Any, Any) -> Bool]) {
        self.name = name
        self.argumentMatchers = argumentMatchers
        self.resultMatcher = { (a, b) -> Bool in
            return false
        }
    }
    
    init(name: String) {
        self.name = name
        self.argumentMatchers = [:]
        self.resultMatcher = { (a, b) -> Bool in
            return false
        }
    }
    
}

class MockCall {
    
    let function: MockFunction
    let arguments: [String: Any?]
    let result: Any?
    
    init(function: MockFunction, arguments: [String: Any?], result: Any?) {
        self.function = function
        self.arguments = arguments
        self.result = result
    }
    
    init(function: MockFunction, arguments: [String: Any?]) {
        self.function = function
        self.arguments = arguments
        self.result = nil
    }
    
    init(function: MockFunction) {
        self.function = function
        self.arguments = [:]
        self.result = nil
    }
    
}

enum MockMode {
    case record
    case expect
}

class MockObject {
    
    var mode: MockMode = .record
    
    var recordedCalls: [MockCall] = []
    var expectedCalls: [MockCall] = []

    func remember(call: MockCall) {
        switch mode {
        case .record:
            recordedCalls += [call]
        case .expect:
            expectedCalls += [call]
        }
    }
    
    static func isEqualAs<T: Equatable>(type: T.Type, a: Any, b: Any) -> Bool {
        guard let a = a as? T, let b = b as? T else {
            return false
        }
        return a == b
    }
    
    func isEqual(a: MockCall, b: MockCall) -> Bool {
        if a.function !== b.function {
            return false
        }
        let function = a.function
        if (a.result == nil) != (b.result == nil) {
            return false
        }
        if let aResult = a.result, let bResult = b.result {
            if !function.resultMatcher(aResult, bResult) {
                return false
            }
        }
        if a.arguments.count != b.arguments.count {
            return false
        }
        for (name, aValue) in a.arguments {
            guard let bValue = b.arguments[name] else {
                return false
            }
            if (aValue == nil) != (bValue == nil) {
                return false
            }
            if let aValue = aValue, let bValue = bValue {
                guard let matcher = function.argumentMatchers[name] else {
                    return false
                }
                if !matcher(aValue, bValue) {
                    return false
                }
            }
        }
        return true
    }
    
    func verify() -> Bool {
        if recordedCalls.count != expectedCalls.count {
            return false
        }
        for i in 0 ..< recordedCalls.count {
            let recordedCall = recordedCalls[i]
            let expectedCall = expectedCalls[i]
            if !isEqual(a: recordedCall, b: expectedCall) {
                return false
            }
        }
        return true
    }
    
}

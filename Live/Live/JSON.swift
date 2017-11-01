//
//  JSON.swift
//  Live
//
//  Created by Denis Bohm on 1/4/17.
//  Copyright © 2017 Firefly Design LLC. All rights reserved.
//

import Foundation

protocol JSONConvertable {

    init(json: [String: Any]) throws

    func json() -> [String: Any]

}

class JSON {

    enum SerializationError: Error {
        case missing(String)
        case invalid(String)
    }

    static func newDateFormatter() -> DateFormatter {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return dateFormatter
    }

    static let dateFormatter = newDateFormatter()

    static func json(bool: Bool) -> Bool {
        return bool
    }

    static func jsonBool(json: [String: Any], key: String) throws -> Bool {
        guard let bool = json[key] as? Bool else {
            throw SerializationError.missing(key)
        }
        return bool
    }

    static func jsonDefaultBool(json: [String: Any], key: String, fallback: Bool = false) throws -> Bool {
        if json[key] == nil {
            return fallback
        }
        return try jsonBool(json: json, key: key)
    }

    static func json(int: Int) -> Int {
        return int
    }

    static func jsonInt(json: [String: Any], key: String) throws -> Int {
        guard let int = json[key] as? Int else {
            throw SerializationError.missing(key)
        }
        return int
    }

    static func jsonOptionalInt(json: [String: Any], key: String) throws -> Int? {
        if json[key] == nil {
            return nil
        }
        return try jsonInt(json: json, key: key)
    }
    
    static func json(double: Double) -> Double {
        return double
    }

    static func jsonDouble(json: [String: Any], key: String) throws -> Double {
        guard let double = json[key] as? Double else {
            throw SerializationError.missing(key)
        }
        return double
    }

    static func jsonOptionalDouble(json: [String: Any], key: String) throws -> Double? {
        if json[key] == nil {
            return nil
        }
        return try jsonDouble(json: json, key: key)
    }
    
    static func json(string: String) -> String {
        return string
    }

    static func jsonString(json: [String: Any], key: String) throws -> String {
        guard let string = json[key] as? String else {
            throw SerializationError.missing(key)
        }
        return string
    }

    static func jsonOptionalString(json: [String: Any], key: String) throws -> String? {
        if json[key] == nil {
            return nil
        }
        return try jsonString(json: json, key: key)
    }

    static func json(dictionary: [String: Any]) -> [String: Any] {
        return dictionary
    }

    static func jsonStringAnyDictionary(json: [String: Any], key: String) throws -> [String: Any] {
        guard let dictionary = json[key] as? [String: Any] else {
            throw SerializationError.missing(key)
        }
        return dictionary
    }
    
    static func jsonDefaultStringAnyDictionary(json: [String: Any], key: String, fallback: [String: Any]) throws -> [String: Any] {
        if json[key] == nil {
            return fallback
        }
        return try jsonStringAnyDictionary(json: json, key: key)
    }

    static func json(date: Date) -> String {
        return dateFormatter.string(from: date)
    }

    static func jsonDate(json: [String: Any], key: String) throws -> Date {
        guard let string = json[key] as? String else {
            throw SerializationError.missing(key)
        }
        guard let date = dateFormatter.date(from: string) else {
            throw SerializationError.invalid(string)
        }
        return date
    }

    static func jsonOptionalDate(json: [String: Any], key: String) throws -> Date? {
        if json[key] == nil {
            return nil
        }
        return try jsonDate(json: json, key: key)
    }

    static func jsonDefaultDate(json: [String: Any], key: String, fallback: Date) throws -> Date {
        if json[key] == nil {
            return fallback
        }
        return try jsonDate(json: json, key: key)
    }

    static func json<T>(object: T) -> Any where T: JSONConvertable {
        return object.json()
    }

    static func jsonObject<T>(json: [String: Any]) throws -> T where T: JSONConvertable {
        return try T(json: json)
    }

    static func jsonObject<T>(json: [String: Any], key: String) throws -> T where T: JSONConvertable {
        guard let jsonDictionary = json[key] as? [String: Any] else {
            throw SerializationError.missing(key)
        }
        return try T(json: jsonDictionary)
    }

    static func jsonOptionalObject<T>(json: [String: Any], key: String) throws -> T? where T: JSONConvertable {
        if json[key] == nil {
            return nil
        }
        let result: T = try jsonObject(json: json, key: key)
        return result
    }

    static func jsonDefaultObject<T>(json: [String: Any], key: String, fallback: T) throws -> T where T: JSONConvertable {
        if json[key] == nil {
            return fallback
        }
        return try jsonObject(json: json, key: key)
    }

    static func json<T>(array: [T]) -> [Any] where T: JSONConvertable {
        return array.map { $0.json() }
    }

    static func jsonArray<T>(json: Any) throws -> [T] where T: JSONConvertable {
        var array: [T] = []
        if let jsonElements = json as? [Any] {
            for jsonElementMaybe in jsonElements {
                if let jsonElement = jsonElementMaybe as? [String: Any] {
                    if let element = try? T(json: jsonElement) {
                        array.append(element)
                    }
                }
            }
        }
        return array
    }

    static func jsonArray<T>(json: [String: Any], key: String) throws -> [T] where T: JSONConvertable {
        guard let jsonArrayMaybe = json[key] else {
            throw SerializationError.missing(key)
        }
        return try jsonArray(json: jsonArrayMaybe)
    }

    static func jsonArray<T>(json: [String: Any], key: String, fallback: [T]) throws -> [T] where T: JSONConvertable {
        if json[key] == nil {
            return fallback
        }
        return try jsonArray(json: json, key: key)
    }
    
    static func json(array: [String]) -> [Any] {
        return array
    }

    static func jsonArray(json: [String: Any], key: String) throws -> [String] {
        guard let jsonArrayMaybe = json[key] else {
            throw SerializationError.missing(key)
        }
        guard let jsonArray = jsonArrayMaybe as? [String] else {
            throw SerializationError.invalid(key)
        }
        return jsonArray
    }

    static func json(data: Data) throws -> Any {
        if let json = try? JSONSerialization.jsonObject(with: data, options: []) {
            return json
        }
        throw SerializationError.invalid(String(data: data, encoding: String.Encoding.utf8) ?? "")
    }

    static func json(any: Any) throws -> Data {
        if let data = try? JSONSerialization.data(withJSONObject: any, options: [.prettyPrinted]) {
            return data
        }
        throw SerializationError.invalid("\(any)")
    }

}

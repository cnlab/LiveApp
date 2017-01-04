//
//  Note.swift
//  Live
//
//  Created by Denis Bohm on 10/15/16.
//  Copyright © 2016 Firefly Design LLC. All rights reserved.
//

import Foundation

class Note: JSONConvertable {

    enum Status: JSONConvertable {

        case pending
        case expired
        case closed
        case rated(date: Date, rank: Double)

        init(json: [String: Any]) throws {
            let type = try JSON.jsonString(json: json, key: "type")
            switch type {
            case "pending":
                self = .pending
            case "expired":
                self = .expired
            case "closed":
                self = .closed
            case "rated":
                let date = try JSON.jsonDate(json: json, key: "date")
                let rank = try JSON.jsonDouble(json: json, key: "rank")
                self = .rated(date: date, rank: rank)
            default:
                throw JSON.SerializationError.invalid(type)
            }
        }

        func json() -> [String: Any] {
            switch self {
            case .pending:
                return ["type": "pending"]
            case .expired:
                return ["type": "expired"]
            case .closed:
                return ["type": "closed"]
            case .rated(let date, let rank):
                return [
                    "type": "rated",
                    "date": JSON.json(date: date),
                    "rank": JSON.json(double: rank)
                ]
            }
        }

        var isRated: Bool {
            get {
                if case Note.Status.rated(date: _, rank: _) = self {
                    return true
                }
                return false
            }
        }

    }

    let uuid: String
    let type: String
    let messageKey: Message.Key
    var status: Status

    init(uuid: String, type: String, messageKey: Message.Key, status: Status) {
        self.uuid = uuid
        self.type = type
        self.messageKey = messageKey
        self.status = status
    }

    required init(json: [String: Any]) throws {
        let uuid = try JSON.jsonString(json: json, key: "uuid")
        let type = try JSON.jsonString(json: json, key: "type")
        let messageKey: Message.Key = try JSON.jsonObject(json: json, key: "messageKey")
        let status: Status = try JSON.jsonObject(json: json, key: "status")

        self.uuid = uuid
        self.type = type
        self.messageKey = messageKey
        self.status = status
    }

    func json() -> [String: Any] {
        return [
            "uuid": JSON.json(string: uuid),
            "type": JSON.json(string: type),
            "messageKey": JSON.json(object: messageKey),
            "status": JSON.json(object: status),
        ]
    }

    var isPending: Bool {
        get {
            if case .pending = status {
                return true
            }
            return false
        }
    }
    
}

//
//  Note.swift
//  Live
//
//  Created by Denis Bohm on 10/15/16.
//  Copyright © 2016 Firefly Design LLC. All rights reserved.
//

import Foundation

class Note: JSONConvertable {

    // pending: The note is scheduled for a future date.
    // current: The note is current.
    // expired: The note has expired (there is a newer current note).
    // closed: The note is not registered in the notifcation manager any longer.
    enum Status: JSONConvertable {

        case pending
        case current
        case expired
        case closed

        init(json: [String: Any]) throws {
            let type = try JSON.jsonString(json: json, key: "type")
            switch type {
            case "pending":
                self = .pending
            case "current":
                self = .current
            case "expired":
                self = .expired
            case "closed":
                self = .closed
            default:
                throw JSON.SerializationError.invalid(type)
            }
        }

        func json() -> [String: Any] {
            switch self {
            case .pending:
                return ["type": "pending"]
            case .current:
                return ["type": "current"]
            case .expired:
                return ["type": "expired"]
            case .closed:
                return ["type": "closed"]
            }
        }

    }

    struct Rating: JSONConvertable {

        let date: Date
        let rank: Double

        init(date: Date, rank: Double) {
            self.date = date
            self.rank = rank
        }
        
        init(json: [String: Any]) throws {
            let date = try JSON.jsonDate(json: json, key: "date")
            let rank = try JSON.jsonDouble(json: json, key: "rank")

            self.date = date
            self.rank = rank
        }

        func json() -> [String: Any] {
            return [
                "date": JSON.json(date: date),
                "rank": JSON.json(double: rank),
            ]
        }
        
    }

    let uuid: String
    let type: String
    let messageKey: Message.Key
    var status: Status
    var deleted: Bool
    var rating: Rating?

    init(uuid: String, type: String, messageKey: Message.Key, status: Status, deleted: Bool) {
        self.uuid = uuid
        self.type = type
        self.messageKey = messageKey
        self.status = status
        self.deleted = deleted
    }

    required init(json: [String: Any]) throws {
        let uuid = try JSON.jsonString(json: json, key: "uuid")
        let type = try JSON.jsonString(json: json, key: "type")
        let messageKey: Message.Key = try JSON.jsonObject(json: json, key: "messageKey")
        let status: Status = try JSON.jsonObject(json: json, key: "status")
        let rating: Rating? = try JSON.jsonOptionalObject(json: json, key: "rating")
        let deleted: Bool = try JSON.jsonDefaultBool(json: json, key: "deleted", fallback: false)

        self.uuid = uuid
        self.type = type
        self.messageKey = messageKey
        self.status = status
        self.deleted = deleted
        self.rating = rating
    }

    func json() -> [String: Any] {
        var values: [String: Any] = [
            "uuid": JSON.json(string: uuid),
            "type": JSON.json(string: type),
            "messageKey": JSON.json(object: messageKey),
            "status": JSON.json(object: status),
            "deleted": JSON.json(bool: deleted),
        ]
        if let rating = rating {
            values["rating"] = rating.json()
        }
        return values
    }

    var isPending: Bool {
        get {
            if case .pending = status {
                return true
            }
            return false
        }
    }

    var isCurrent: Bool {
        get {
            if case .current = status {
                return true
            }
            return false
        }
    }

}

//
//  Note.swift
//  Live
//
//  Created by Denis Bohm on 10/15/16.
//  Copyright © 2016 Firefly Design LLC. All rights reserved.
//

import Foundation

class Note : NSObject, NSCoding {

    enum Status {
        case pending
        case expired
        case closed
        case rated(date: Date, rank: Double)
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

    required convenience init?(coder decoder: NSCoder) {
        guard
            let uuid = decoder.decodeObject(forKey: "uuid") as? String,
            let type = decoder.decodeObject(forKey: "type") as? String,
            let messageKey = decoder.decodeObject(forKey: "messageKey") as? Message.Key,
            let statusType = decoder.decodeObject(forKey: "statusType") as? String
            else {
                return nil
        }
        var status: Status? = nil
        switch statusType {
        case "pending":
            status = .pending
        case "expired":
            status = .expired
        case "closed":
            status = .closed
        case "rated":
            if let date = decoder.decodeObject(forKey: "statusRatedDate") as? Date {
                let rank = decoder.decodeDouble(forKey: "statusRatedRank")
                status = .rated(date: date, rank: rank)
            }
        default:
            break
        }
        guard let theStatus = status else {
            return nil
        }
        self.init(uuid: uuid, type: type, messageKey: messageKey, status: theStatus)
    }

    func encode(with encoder: NSCoder) {
        encoder.encode(uuid, forKey: "uuid")
        encoder.encode(type, forKey: "type")
        encoder.encode(messageKey, forKey: "messageKey")
        switch status {
        case .pending:
            encoder.encode("pending", forKey: "statusType")
        case .expired:
            encoder.encode("expired", forKey: "statusType")
        case .closed:
            encoder.encode("closed", forKey: "statusType")
        case .rated(let date, let rank):
            encoder.encode("rated", forKey: "statusType")
            encoder.encode(date, forKey: "statusRatedDate")
            encoder.encode(rank, forKey: "statusRatedRank")
        }
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

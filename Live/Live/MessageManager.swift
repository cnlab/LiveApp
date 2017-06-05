//
//  MessageManager.swift
//  Live
//
//  Created by Denis Bohm on 9/12/16.
//  Copyright © 2016 Firefly Design LLC. All rights reserved.
//

import Foundation

class Message {

    class Key: JSONConvertable {

        let group: String
        let identifier: String

        init(group: String, identifier: String) {
            self.group = group
            self.identifier = identifier
        }

        required init(json: [String: Any]) throws {
            let group = try JSON.jsonString(json: json, key: "group")
            let identifier = try JSON.jsonString(json: json, key: "identifier")

            self.group = group
            self.identifier = identifier
        }

        func json() -> [String: Any] {
            return [
                "group": JSON.json(string: group),
                "identifier": JSON.json(string: identifier),
            ]
        }

    }

    let key: Key
    let string: String
    let variants: [String: [String: String]]

    init(group: String, identifier: String, string: String, variants: [String: [String: String]] = [:]) {
        self.key = Key(group: group, identifier: identifier)
        self.string = string
        self.variants = variants
    }

    init(group: String, identifier: String, alternatives: (variant: String, string: String)...) {
        self.key = Key(group: group, identifier: identifier)
        var variants: [String: [String: String]] = [:]
        self.string = alternatives.first!.string
        for (variant, string) in alternatives.dropFirst() {
            variants[variant] = [self.string: string]
        }
        self.variants = variants
    }

    func format(variant: String? = nil) -> String {
        let parts = string.components(separatedBy: "/")
        if let variant = variant {
            if let substitutions = variants[variant] {
                var string = ""
                for part in parts {
                    if let substitution = substitutions[part] {
                        string += substitution
                    } else {
                        string += part
                    }
                }
                return string
            }
        }
        return parts.joined()
    }

}

protocol MessageManager {

    var type: String { get }
    
    var messages: [Message] { get }

    func find(group: String, identifier: String) -> Message?

    func find(messageKey: Message.Key) -> Message?

    func next() -> Message.Key

}

extension MessageManager {

    func find(group: String, identifier: String) -> Message? {
        return messages.first() { ($0.key.group == group) && ($0.key.identifier == identifier) }
    }

    func find(messageKey: Message.Key) -> Message? {
        return find(group: messageKey.group, identifier: messageKey.identifier)
    }
    
}

class MessageSequencer {

    class Group {

        let name: String
        var messageKeys: [Message.Key] = []
        var transitions: [(Int, Int)] = []

        init(name: String) {
            self.name = name
        }

    }

    func getGroups(messages: [Message]) -> [Group] {
        var groupByName = [String: Group]()
        for message in messages {
            let groupName = message.key.group
            var groupMaybe = groupByName[groupName]
            if groupMaybe == nil {
                groupMaybe = Group(name: groupName)
                groupByName[groupName] = groupMaybe
            }
            let group = groupMaybe!
            group.messageKeys.append(message.key)
        }
        return [Group](groupByName.values)
    }

    func getItemPairFrequencyTable(groups: [Int]) -> [[Int]] {
        let count = groups.count
        let t = groups.reduce(0, +)
        var n = [[Double]](repeating: [Double](repeating: Double(), count: count), count: count)
        for i in 0 ..< count {
            for j in 0 ..< count {
                n[i][j] = Double(groups[i] * groups[j]) / Double(t - 1)
            }
        }
        var d = [Double](repeating: Double(), count: count)
        for k in 0 ..< count {
            let Nk = groups[k]
            d[k] = Double(Nk * (Nk - 1)) / Double(t - 1)
        }

        var nt: Double = 0
        for i in 0 ..< count {
            for j in 0 ..< count {
                if i != j {
                    nt += n[i][j]
                }
            }
        }
        var R: Double = 0
        var nv = [Double](repeating: Double(), count: count)
        var s = [Double](repeating: Double(), count: count)
        var Rv = [Double](repeating: Double(), count: count)
        for i in 0 ..< count {
            let rt = round(n[i].reduce(0, +))
            nv[i] = rt - d[i]
            s[i] = nt - 2 * nv[i]
            Rv[i] = d[i] / s[i]
            R += Rv[i]
        }

        for i in 0 ..< count {
            for j in 0 ..< count {
                n[i][j] = i == j ? 0 : Double(groups[i] * groups[j]) / Double(t - 1)
            }
        }

        var f = [[Int]](repeating: [Int](repeating: Int(), count: count), count: count)
        for i in 0 ..< count {
            for j in 0 ..< count {
                if i != j {
                    let fij = round(n[i][j] * (1 - R) + nv[i] * Rv[j] + nv[j] * Rv[i])
                    f[i][j] = Int(fij)
                }
            }
        }
        return f
    }

    func random(upperBound: Int) -> Int {
        return Int(arc4random_uniform(UInt32(upperBound)))
    }

    func consume(groups: [Group], transition: (Int, Int), groupSequence: inout [Group]) {
        groupSequence.append(groups[transition.1])
        let group = groups[transition.0]
        let index = group.transitions.index { $0.1 == transition.1 }!
        group.transitions.remove(at: index)
    }

    func getGroupSequence(groups: [Group], initialGroup: String? = nil) -> [Group] {
        let n = getItemPairFrequencyTable(groups: groups.map { $0.messageKeys.count })
        for i in 0 ..< groups.count {
            let group = groups[i]
            for j in 0 ..< groups.count {
                for _ in 0 ..< n[i][j] {
                    group.transitions.append((i, j))
                }
            }
        }
        var groupSequence = [Group]()
        let transitions: [(Int, Int)]
        if let initialGroup = initialGroup {
            transitions = groups.reduce([(Int, Int)]()) { return $1.name == initialGroup ? $0 + $1.transitions : $0 }
        } else {
            transitions = groups.reduce([(Int, Int)]()) { return $0 + $1.transitions }
        }
        var transition = transitions[random(upperBound: transitions.count)]
        groupSequence.append(groups[transition.0])
        while true {
            consume(groups: groups, transition: transition, groupSequence: &groupSequence)
            let group = groups[transition.1]
            if group.transitions.isEmpty {
                break
            }
            transition = group.transitions[random(upperBound: group.transitions.count)]
        }
        return groupSequence
    }

    // Create a sequence of the given messages in random order.
    // Try to alternate randomly between message groups of "how", "why", and "risk".
    // Note: The calculated item pair frequency table can be off if there is not a "round" number of messages.
    // In that case there may be a couple of stray messages from the same group in sequence. -denis
    //
    // See "Generating constrained randomized sequences: Item frequency matters" 2009 by RobeRt M. FRench and PieRRe PeRRuchet
    func getMessageKeySequence(messages: [Message], initialGroup: String? = nil) -> [Message.Key] {
        var messageKeySequence: [Message.Key] = []
        let groups = getGroups(messages: messages)
        let groupSequence = getGroupSequence(groups: groups, initialGroup: initialGroup)
        for group in groupSequence {
            if group.messageKeys.isEmpty {
                // The item pair frequency table can be off if there are not "round" numbers of messages.
                // Give up on the group sequence if we run out of messages. -denis
                // statistics...  can't live with them...  can't live without them...
                break
            }
            let index = random(upperBound: group.messageKeys.count)
            let messageKey = group.messageKeys.remove(at: index)
            messageKeySequence.append(messageKey)
        }
        // The item pair frequency table can be off if there are not "round" numbers of messages.
        // Insert any strays at random positions. -denis
        let strays = groups.reduce(Array<Message.Key>()) { $0 + $1.messageKeys }
        for messageKey in strays {
            let index = random(upperBound: messageKeySequence.count)
            messageKeySequence.insert(messageKey, at: index)
        }
        return messageKeySequence
    }

    // Create a sequence of the given messages in random order.
    func getMessageKeySequence(messages: [Message], group: String, lastMessage: String? = nil) -> [Message.Key] {
        var messageKeySequence: [Message.Key] = []
        var messages = messages.filter { $0.key.group == group }
        while !messages.isEmpty {
            let index = random(upperBound: messages.count)
            let message = messages.remove(at: index)
            messageKeySequence.append(message.key)
        }
        if  let lastMessage = lastMessage,
            let first = messageKeySequence.first,
            first.identifier == lastMessage,
            messageKeySequence.count > 1
        {
            let messageKey = messageKeySequence.remove(at: 0)
            let index = random(upperBound: messageKeySequence.count - 1)
            messageKeySequence.insert(messageKey, at: index + 1)
        }
        return messageKeySequence
    }

}

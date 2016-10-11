//
//  MessageManager.swift
//  Live
//
//  Created by Denis Bohm on 9/12/16.
//  Copyright © 2016 Firefly Design LLC. All rights reserved.
//

import Foundation

class Message {

    let group: String
    let identifier: String
    let string: String
    let variants: [String: [String: String]]

    init(group: String, identifier: String, string: String, variants: [String: [String: String]] = [:]) {
        self.group = group
        self.identifier = identifier
        self.string = string
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

class MessageKey : NSObject, NSCoding {

    let group: String
    let identifier: String

    init(group: String, identifier: String) {
        self.group = group
        self.identifier = identifier
    }

    required convenience init?(coder decoder: NSCoder) {
        guard
            let group = decoder.decodeObject(forKey: "group") as? String,
            let identifier = decoder.decodeObject(forKey: "identifier") as? String
            else {
                return nil
            }

        self.init(group: group, identifier: identifier)
    }

    func encode(with encoder: NSCoder) {
        encoder.encode(group, forKey: "group")
        encoder.encode(identifier, forKey: "identifier")
    }

}

class MessageManager {

    let messages: [Message]

    var messageSequence = [Message]()

    init(messages: [Message]) {
        self.messages = messages
    }

    func archiveMessageSequence(archiver: NSKeyedArchiver, prefix: String) {
        var keys = [MessageKey]()
        for message in messageSequence {
            keys.append(MessageKey(group: message.group, identifier: message.identifier))
        }
        archiver.encode(keys, forKey: "\(prefix)messageSequence")
    }

    func find(group: String, identifier: String) -> Message? {
        return messages.first() { ($0.group == group) && ($0.identifier == identifier) }
    }

    func unarchiveMessageSequence(unarchiver: NSKeyedUnarchiver, prefix: String) {
        messageSequence.removeAll()
        if let keys = unarchiver.decodeObject(forKey: "\(prefix)messageSequence") as? [MessageKey] {
            for key in keys {
                if let message = find(group: key.group, identifier: key.identifier) {
                    messageSequence.append(message)
                }
            }
        }
    }

    func archive(archiver: NSKeyedArchiver, prefix: String) {
        archiveMessageSequence(archiver: archiver, prefix: prefix)
    }

    func unarchive(unarchiver: NSKeyedUnarchiver, prefix: String) {
        unarchiveMessageSequence(unarchiver: unarchiver, prefix: prefix)
    }
    
}

class MessageSequencer {

    class Group {

        let name: String
        var messages = [Message]()
        var transitions = [(Int, Int)]()

        init(name: String) {
            self.name = name
        }

    }

    func getGroups(messages: [Message]) -> [Group] {
        var groupByName = [String: Group]()
        for message in messages {
            let groupName = message.group
            var groupMaybe = groupByName[groupName]
            if groupMaybe == nil {
                groupMaybe = Group(name: groupName)
                groupByName[groupName] = groupMaybe
            }
            let group = groupMaybe!
            group.messages.append(message)
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
        let n = getItemPairFrequencyTable(groups: groups.map { $0.messages.count })
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
    func getMessageSequence(messages: [Message], initialGroup: String? = nil) -> [Message] {
        var messageSequence = [Message]()
        let groups = getGroups(messages: messages)
        let groupSequence = getGroupSequence(groups: groups, initialGroup: initialGroup)
        for group in groupSequence {
            if group.messages.isEmpty {
                // The item pair frequency table can be off if there are not "round" numbers of messages.
                // Give up on the group sequence if we run out of messages. -denis
                // statistics...  can't live with them...  can't live without them...
                break
            }
            let index = random(upperBound: group.messages.count)
            let message = group.messages.remove(at: index)
            messageSequence.append(message)
        }
        // The item pair frequency table can be off if there are not "round" numbers of messages.
        // Insert any strays at random positions. -denis
        let strays = groups.reduce([Message]()) { $0 + $1.messages }
        for message in strays {
            let index = random(upperBound: messageSequence.count)
            messageSequence.insert(message, at: index)
        }
        return messageSequence
    }

    // Create a sequence of the given messages in random order.
    func getMessageSequence(messages: [Message], group: String, lastMessage: String? = nil) -> [Message] {
        var messageSequence = [Message]()
        var messages = messages.filter { $0.group == group }
        while !messages.isEmpty {
            let index = random(upperBound: messages.count)
            let message = messages.remove(at: index)
            messageSequence.append(message)
        }
        if let lastMessage = lastMessage, let first = messageSequence.first, first.identifier == lastMessage, messageSequence.count > 1 {
            let message = messageSequence.remove(at: 0)
            let index = random(upperBound: messageSequence.count - 1)
            messageSequence.insert(message, at: index + 1)
        }
        return messageSequence
    }

}

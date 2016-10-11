//
//  Archiver.swift
//  Live
//
//  Created by Denis Bohm on 10/10/16.
//  Copyright © 2016 Firefly Design LLC. All rights reserved.
//

import Foundation

class Archiver {

    class func archive<T>(archiver: NSKeyedArchiver, prefix: String, key: String, property: T) {
        archiver.encode(property, forKey: "\(prefix)\(key)")
    }

    class func unarchive<T>(unarchiver: NSKeyedUnarchiver, prefix: String, key: String, property: inout T) {
        if let value = unarchiver.decodeObject(forKey: "\(prefix)\(key)") as? T {
            property = value
        }
    }

}

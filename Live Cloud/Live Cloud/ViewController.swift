//
//  ViewController.swift
//  Live Cloud
//
//  Created by Denis Bohm on 3/10/17.
//  Copyright © 2017 Firefly Design. All rights reserved.
//

import CloudKit
import Cocoa

class ViewController: NSViewController {

    enum LocalError: Error {
        case contentModificationDateNotFound
        case directoryNotFound
        case assetNotFound
    }

    struct State {
        let type: String
        let queryOperation: CKQueryOperation
    }

    var state: State? = nil

    var database: CKDatabase {
        get {
            let container = CKContainer(identifier: "iCloud.com.fireflydesign.Live")
            return container.publicCloudDatabase
        }
    }

    func isOutOfDate(url: URL, date: Date) throws -> Bool {
        if !FileManager.default.fileExists(atPath: url.path) {
            return true
        }
        let values = try url.resourceValues(forKeys: [.contentModificationDateKey])
        guard let contentModificationDate = values.contentModificationDate else {
            throw LocalError.contentModificationDateNotFound
        }
        return date > contentModificationDate
    }

    func queryComplete(records: [CKRecord], error: Error?) {
        state = nil

        if let error = error {
            print("CloudManager.queryComplete Error: \(error.localizedDescription)")
            return
        }
        print("CloudManager.queryComplete success")

        let directory = "\(FileManager.default.homeDirectoryForCurrentUser)/Desktop/Live"
        for record in records {
            if let recordModificationDate = record.modificationDate {
                let name = record.recordID.recordName
                do {
                    guard let destinationURL = URL(string: "\(directory)/\(name)") else {
                        throw LocalError.directoryNotFound
                    }
                    if try isOutOfDate(url: destinationURL, date: recordModificationDate) {
                        guard let asset = record["asset"] as? CKAsset else {
                            throw LocalError.assetNotFound
                        }
                        let data = try Data(contentsOf: asset.fileURL)
                        try data.write(to: destinationURL)
                    }
                } catch {
                    NSLog("can't copy asset: \(error.localizedDescription)")
                }
            }
        }
    }

    func query(type: String) {
        if state != nil {
            NSLog("query already in progress...")
            return
        }

        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: type, predicate: predicate)
        let operation = CKQueryOperation(query: query)
        operation.qualityOfService = .userInteractive
        var records: [CKRecord] = []
        operation.recordFetchedBlock = { (record) in
            records.append(record)
            print("query record \(record)")
        }
        operation.queryCompletionBlock = { (cursor, error) in
            DispatchQueue.main.async {
                self.queryComplete(records: records, error: error)
            }
        }
        state = State(type: type, queryOperation: operation)
        database.add(operation)
    }

    @IBAction func sync(_ sender: AnyObject) {
        query(type: "Archive")
    }

}


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

    @IBOutlet var syncButton: NSButton?
    @IBOutlet var syncProgressIndicator: NSProgressIndicator?
    @IBOutlet var logTextView: NSTextView?
    
    enum LocalError: Error {
        case contentModificationDateNotFound
        case directoryNotFound
        case assetNotFound
    }

    struct State {
        let type: String
        let completionClosure: () -> Void
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
        let completionClosure = state?.completionClosure
        state = nil
        defer {
            completionClosure?()
        }

        if let error = error {
            log("iCloud query error: \(error.localizedDescription)")
            return
        }
        log("iCloud query completed...")

        let directory = "\(FileManager.default.homeDirectoryForCurrentUser)/Desktop/Live"
        for record in records {
            if let recordModificationDate = record.modificationDate {
                let name = record.recordID.recordName
                do {
                    guard let destinationURL = URL(string: "\(directory)/\(name)-archive.json") else {
                        throw LocalError.directoryNotFound
                    }
                    if try isOutOfDate(url: destinationURL, date: recordModificationDate) {
                        guard let asset = record["asset"] as? CKAsset else {
                            throw LocalError.assetNotFound
                        }
                        let data = try Data(contentsOf: asset.fileURL)
                        try data.write(to: destinationURL)
                        log("updated out of date asset for UUID " + record.recordID.recordName)
                    } else {
                        log("skipping up to date asset for UUID " + record.recordID.recordName)
                    }
                } catch {
                    log("can't copy asset: \(error.localizedDescription)")
                }
            }
        }
    }

    func query(type: String, completionClosure: @escaping () -> Void) {
        if state != nil {
            debug("query already in progress!")
            completionClosure()
            return
        }

        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: type, predicate: predicate)
        let operation = CKQueryOperation(query: query)
        operation.qualityOfService = .userInteractive
        var records: [CKRecord] = []
        operation.recordFetchedBlock = { (record) in
            DispatchQueue.main.async {
                records.append(record)
                self.debug("query record \(record)")
            }
        }
        operation.queryCompletionBlock = { (cursor, error) in
            DispatchQueue.main.async {
                self.queryComplete(records: records, error: error)
            }
        }
        state = State(type: type, completionClosure: completionClosure, queryOperation: operation)
        log("Querying iCloud for asset metadata...")
        database.add(operation)
    }

    @IBAction func sync(_ sender: AnyObject) {
        syncButton?.isEnabled = false
        syncProgressIndicator?.isHidden = false
        syncProgressIndicator?.startAnimation(self)
        logTextView?.textStorage?.mutableString.setString("")
        query(type: "Archive") {
            self.syncButton?.isEnabled = true
            self.syncProgressIndicator?.stopAnimation(self)
            self.syncProgressIndicator?.isHidden = true
        }
    }

    func log(_ string: String) {
        logTextView?.textStorage?.mutableString.append(string + "\n")
    }

    func debug(_ string: String) {
//        logTextView?.textStorage?.mutableString.append(string + "\n")
    }

}


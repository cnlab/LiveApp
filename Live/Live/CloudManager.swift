//
//  CloudManager.swift
//  Live
//
//  Created by Denis Bohm on 3/8/17.
//  Copyright © 2017 Firefly Design LLC. All rights reserved.
//

import CloudKit
import Foundation

class CloudManager {

    struct State {
        let type: String
        let name: String
        let fileURL: URL
        let modificationDate: Date
        let queryOperation: CKQueryOperation
        var modifyOperation: CKModifyRecordsOperation?
    }

    var state: State? = nil
    var lastModificationDate: Date? = nil

    var updateTimeInterval: TimeInterval = 60

    var database: CKDatabase {
        get {
            let container = CKContainer.default()
            return container.publicCloudDatabase
        }
    }

    func saveComplete(error: Error?) {
        if let error = error {
            print("CloudManager.saveComplete error: \(error.localizedDescription)")
        } else {
            print("CloudManager.saveComplete success")
        }

        state = nil
    }

    func save() {
        guard let state = state else {
            NSLog("CloudManager.save expected state != nil")
            return
        }

        let recordID = CKRecordID(recordName: state.name)
        let record = CKRecord(recordType: state.type, recordID: recordID)
        record["assetModificationDate" ] = state.modificationDate as NSDate
        record["asset"] = CKAsset(fileURL: state.fileURL)
        let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        operation.qualityOfService = .userInteractive
        operation.savePolicy = .allKeys
        operation.modifyRecordsCompletionBlock = { (records, recordIDs, error) -> Void in
            DispatchQueue.main.async {
                self.saveComplete(error: error)
            }
        }
        self.state!.modifyOperation = operation
        database.add(operation)
    }

    func withinUpdateTimeInterval() -> Bool {
        guard let lastModificationDate = lastModificationDate else {
            return false
        }
        let deadline = lastModificationDate.addingTimeInterval(updateTimeInterval)
        let now = Date()
        return now < deadline
    }

    func queryComplete(record: CKRecord?, error: Error?) {
        if let error = error {
            print("CloudManager.queryComplete Error: \(error.localizedDescription)")
            state = nil
            return
        }
        print("CloudManager.queryComplete success")

        if
            let record = record,
            let recordModificationDate = record.modificationDate
        {
            lastModificationDate = recordModificationDate
            if withinUpdateTimeInterval() {
                state = nil
                return
            }
        }

        save()
    }

    func update(type: String, name: String, fileURL: URL, modificationDate: Date) {
        if state != nil {
            NSLog("CloudManager.update already in progress...")
            return
        }

        if withinUpdateTimeInterval() {
            return
        }

        let predicate = NSPredicate(format: "recordID = %@", CKRecordID(recordName: name))
        let query = CKQuery(recordType: type, predicate: predicate)
        let operation = CKQueryOperation(query: query)
        operation.qualityOfService = .userInteractive
        operation.desiredKeys = ["modificationDate"]
        var resultRecord: CKRecord? = nil
        operation.recordFetchedBlock = { (record) in
            resultRecord = record
            print("CloudManager.update record \(record)")
        }
        operation.queryCompletionBlock = { (cursor, error) in
            DispatchQueue.main.async {
                self.queryComplete(record: resultRecord, error: error)
            }
        }
        state = State(type: type, name: name, fileURL: fileURL, modificationDate: modificationDate, queryOperation: operation, modifyOperation: nil)
        database.add(operation)
    }

}

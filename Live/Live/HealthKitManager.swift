//
//  HealthKitManager.swift
//  Live
//
//  Created by Denis Bohm on 9/12/16.
//  Copyright © 2016 Firefly Design LLC. All rights reserved.
//

import HealthKit

class HealthKitManager {

    enum LocalError : Error {
        case healthDataNotAvailable
    }

    let identifierDateOfBirth = HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.dateOfBirth)!
    let identifierBiologicalSex = HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.biologicalSex)!
    let identifierBodyMass = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!
    let identifierHeight = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height)!
    let identifierStepCount = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!

    var bodyMass: HKQuantitySample? = nil
    var height: HKQuantitySample? = nil

    let healthStore = HKHealthStore()

    func authorizeHealthKit(_ completion: @escaping ((_ success: Bool, _ error: NSError?) -> Void)) throws {
        if !HKHealthStore.isHealthDataAvailable() {
            throw LocalError.healthDataNotAvailable
        }

        let typesToRead = Set(arrayLiteral:
            identifierDateOfBirth,
            identifierBiologicalSex,
            identifierBodyMass,
            identifierHeight,
            identifierStepCount
        )
        let typesToWrite = Set(arrayLiteral:
            identifierBodyMass,
            identifierHeight
        )
        healthStore.requestAuthorization(toShare: typesToWrite, read: typesToRead) {
            (success, error) -> Void in

            completion(success, error as NSError?)
        }
    }

    func dateOfBirth() throws -> Date {
        return try healthStore.dateOfBirth()
    }

    func biologicalSex() throws -> HKBiologicalSex {
        return try healthStore.biologicalSex().biologicalSex
    }

    func queryMostRecentSample(_ sampleType: HKSampleType, completion: @escaping ((_ sample: HKQuantitySample?) -> Void)) {
        let past = Date.distantPast
        let now = Date()
        let mostRecentPredicate = HKQuery.predicateForSamples(withStart: past, end: now, options: HKQueryOptions())
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let limit = 1
        let sampleQuery = HKSampleQuery(sampleType: sampleType, predicate: mostRecentPredicate, limit: limit, sortDescriptors: [sortDescriptor]) {
            (sampleQuery, results, error) -> Void in

            if let error = error {
                print("HKSampleQuery error: \(error)")
            }

            let mostRecentSample = results?.first as? HKQuantitySample
            completion(mostRecentSample)
        }

        self.healthStore.execute(sampleQuery)
    }

    func queryMostRecentSamples() {
        queryMostRecentSample(identifierBodyMass) { self.bodyMass = $0 }
        queryMostRecentSample(identifierHeight) { self.height = $0 }
    }

    func saveSample(_ sampleType: HKQuantityType, value: Double) {
        let date = Date()
        let quantity = HKQuantity(unit: HKUnit.count(), doubleValue: value)
        let sample = HKQuantitySample(type: sampleType, quantity: quantity, start: date, end: date)
        healthStore.save(sample, withCompletion: {
            (success, error) -> Void in

            if let error = error {
                print("Error saving sample: \(error)")
            } else {
                print("Sample saved successfully!")
            }
        })
    }

    func saveSamples(_ height: Double, bodyMass: Double) {
        saveSample(identifierHeight, value: height)
        saveSample(identifierBodyMass, value: bodyMass)
    }

    func numberOfDays(from: Date, to: Date, timeZone: TimeZone? = nil) -> Int {
        let calendar = Calendar.current
        let date1 = calendar.startOfDay(for: from)
        let date2 = calendar.startOfDay(for: to)
        let components = calendar.dateComponents([Calendar.Component.day], from: date1, to: date2)
        return components.day!
    }

    func queryLastWeekOfDailyStepCounts(handler: @escaping (_ startDate: Date, _ stepCounts: [Int?]) -> Void) -> Date {
        var intervalComponents = DateComponents()
        intervalComponents.day = 1

        let now = Date()
        let calendar = Calendar.current
        var anchorComponents = (calendar as NSCalendar).components([.day, .month, .year], from: now)
        anchorComponents.hour = 0
        let anchorDate = calendar.date(from: anchorComponents)!

        var oneDayOffsetComponents = DateComponents()
        oneDayOffsetComponents.day = 1
        let endDate = (calendar as NSCalendar).date(byAdding: oneDayOffsetComponents, to: anchorDate, options: [])!
        var oneWeekOffsetComponents = DateComponents()
        oneWeekOffsetComponents.day = -7
        let startDate = (calendar as NSCalendar).date(byAdding: oneWeekOffsetComponents, to: endDate, options: [])!

        let query = HKStatisticsCollectionQuery(
            quantityType: identifierStepCount,
            quantitySamplePredicate: nil,
            options: .cumulativeSum,
            anchorDate: anchorDate,
            intervalComponents: intervalComponents
        )
        query.initialResultsHandler = {
            (query, results, error) in

            var stepCounts = [Int?](repeating: 0, count: 7)
            if let results = results {
                results.enumerateStatistics(from: startDate, to: endDate) {
                    statistics, stop in

                    if let quantity = statistics.sumQuantity() {
                        let stepCount = Int(quantity.doubleValue(for: HKUnit.count()))
                        let day = self.numberOfDays(from: startDate, to: statistics.startDate)
                        print("step count \(startDate) \(day) \(stepCount)")
                        stepCounts[day] = stepCount
                    }
                }
            }
            DispatchQueue.main.async {
                handler(startDate, stepCounts)
            }
        }

        healthStore.execute(query)

        return startDate
    }

}

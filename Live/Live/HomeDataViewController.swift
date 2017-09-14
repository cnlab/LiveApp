//
//  HomeDataViewController.swift
//  Live
//
//  Created by Denis Bohm on 9/14/17.
//  Copyright © 2017 Firefly Design LLC. All rights reserved.
//

import UIKit

class HomeDataViewController: UIViewController {
    
    @IBOutlet var motivationalLabel: UILabel?
    @IBOutlet var stepsView: StepsView?
    @IBOutlet var averageStepsLabel: UILabel?
    @IBOutlet var dateLabel: UILabel?

    @IBInspectable var averageStepsInsufficientData: String = ""
    @IBInspectable var averageSteps: String = "Average Daily Steps: /steps/"
    
    @IBInspectable var motivationalInsufficientData: String = "No steps?  Get going and we'll show your progress."
    @IBInspectable var motivationalBelowRatio: Double = 0.9
    @IBInspectable var motivationalBelow: String = "Keep at it. Can you beat your average?"
    @IBInspectable var motivationalAlmost: String = "Getting close. You almost beat your average yesterday!"
    @IBInspectable var motivationalAbove: String = "Great work yesterday! You beat your average by /percent/%"
    
    func substitute(string: String, substitutions: [String : String]) -> String {
        let parts = string.components(separatedBy: "/")
        var result = ""
        for part in parts {
            if let substitution = substitutions[part] {
                result += substitution
            } else {
                result += part
            }
        }
        return result
    }
    
    func calculateAverage(values: [Int?]) -> Int? {
        let usableValues = values.filter() { ($0 != nil) && ($0! != 0) }
        if usableValues.count == 0 {
            return nil
        }
        return (usableValues.reduce(0) { $0 + $1! }) / usableValues.count
    }
    
    func dailyStepCountsChanged() {
        let stepCounts: [Int?]
        let liveManager = LiveManager.shared
        if let dailyStepCounts = liveManager.dailyStepCounts.value {
            let sixDayAverageStepCount = calculateAverage(values: Array(dailyStepCounts.stepCounts[0...5]))
            let todayStepCount = dailyStepCounts.stepCounts[6] ?? 0
            let todayImage: UIImage?
            if todayStepCount < 100 {
                todayImage = UIImage(named: "ic_standing")
            } else
                if let average = sixDayAverageStepCount, todayStepCount > average {
                    todayImage = UIImage(named: "ic_running")
                } else {
                    todayImage = UIImage(named: "ic_walking")
            }
            stepsView?.update(startDate: dailyStepCounts.startDate, stepCounts: dailyStepCounts.stepCounts, todayImage: todayImage)
            stepCounts = dailyStepCounts.stepCounts
        } else {
            stepCounts = [nil, nil, nil, nil, nil, nil, nil]
            if liveManager.didAuthorizeHealthKit {
                stepsView?.update(startDate: Date(), stepCounts: stepCounts, todayImage: UIImage(named: "ic_standing"))
            } else {
                stepsView?.setDefaults()
            }
        }
        
        if
            let fiveDayAverageStepCount = calculateAverage(values: Array(stepCounts[0...4])),
            let yesterdaysStepCount = stepCounts[5]
        {
            let ratio = Double(yesterdaysStepCount) / Double(fiveDayAverageStepCount)
            if ratio < motivationalBelowRatio {
                let percent = Int(floor((1.0 - ratio) * 100.0))
                motivationalLabel?.text = substitute(string: motivationalBelow, substitutions: ["percent": "\(percent)"])
            } else
                if ratio < 1.0 {
                    let percent = Int(floor((1.0 - ratio) * 100.0))
                    motivationalLabel?.text = substitute(string: motivationalAlmost, substitutions: ["percent": "\(percent)"])
                } else {
                    let percent = Int(ceil((ratio - 1.0) * 100.0))
                    motivationalLabel?.text = substitute(string: motivationalAbove, substitutions: ["percent": "\(percent)"])
            }
        } else {
            motivationalLabel?.text = motivationalInsufficientData
        }
        
        if let sixDayAverageStepCount = calculateAverage(values: Array(stepCounts[0...5])) {
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = NumberFormatter.Style.decimal
            let steps = numberFormatter.string(for: sixDayAverageStepCount) ?? "?"
            averageStepsLabel?.text = substitute(string: averageSteps, substitutions: ["steps": steps])
        } else {
            averageStepsLabel?.text = averageStepsInsufficientData
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM YYYY"
        dateLabel?.text = dateFormatter.string(from: Date())
    }

}

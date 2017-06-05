//
//  HomeViewController.swift
//  Live
//
//  Created by Denis Bohm on 9/9/16.
//  Copyright © 2016 Firefly Design LLC. All rights reserved.
//

import UIKit
import LiveViews

class HomeViewController: UIViewController {

    @IBOutlet var motivationalLabel: UILabel?
    @IBOutlet var stepsView: StepsView?
    @IBOutlet var stepsButton: UIButton?
    @IBOutlet var averageStepsLabel: UILabel?
    @IBOutlet var valueTextView: UITextView?
    @IBOutlet var activityTextView: UITextView?

    @IBInspectable var averageStepsInsufficientData: String = "No steps? Get going and we'll show your progress."
    @IBInspectable var averageSteps: String = "Average Daily Steps: /steps/"

    @IBInspectable var motivationalInsufficientData: String = "Welcome To Live Active!"
    @IBInspectable var motivationalBelowRatio: Double = 0.9
    @IBInspectable var motivationalBelow: String = "Keep at it. Can you beat your average?"
    @IBInspectable var motivationalAlmost: String = "Getting close. You almost beat your average yesterday!"
    @IBInspectable var motivationalAbove: String = "Great work yesterday! You beat your average by /percent/%"

    override func viewDidLoad() {
        super.viewDidLoad()

        let valueRecognizer = UITapGestureRecognizer(target: self, action: #selector(respondToValueTouched))
        valueTextView?.addGestureRecognizer(valueRecognizer)

        let activityRecognizer = UITapGestureRecognizer(target: self, action: #selector(respondToActivityTouched))
        activityTextView?.addGestureRecognizer(activityRecognizer)

        let liveManager = LiveManager.shared
        liveManager.dailyStepCounts.subscribe(owner: self, observer: dailyStepCountsChanged)
        liveManager.valueNote.subscribe(owner: self, observer: valueChanged)
        liveManager.activityNote.subscribe(owner: self, observer: activityChanged)

        dailyStepCountsChanged()
        valueChanged()
        activityChanged()
    }

    open override func viewDidLayoutSubviews() {
        Layout.vertical(viewController: self, flexibleView: stepsView!)
        stepsButton!.frame.size = stepsView!.frame.size
    }

    func calculateAverage(values: [Int?]) -> Int? {
        let usableValues = values.filter() { ($0 != nil) && ($0! != 0) }
        if usableValues.count == 0 {
            return nil
        }
        return (usableValues.reduce(0) { $0 + $1! }) / usableValues.count
    }

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

    func dailyStepCountsChanged() {
        let stepCounts: [Int?]
        let liveManager = LiveManager.shared
        if let dailyStepCounts = liveManager.dailyStepCounts.value {
            stepsButton?.isHidden = true
            stepsView?.isEnabled = true
            stepsView?.update(startDate: dailyStepCounts.startDate, stepCounts: dailyStepCounts.stepCounts)
            stepCounts = dailyStepCounts.stepCounts
        } else {
            stepCounts = [nil, nil, nil, nil, nil, nil, nil]
            stepsView?.isEnabled = false
            if liveManager.didAuthorizeHealthKit {
                stepsButton?.isHidden = true
                stepsView?.update(startDate: Date(), stepCounts: stepCounts)
            } else {
                stepsButton?.isHidden = false
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
    }

    func showMessage(view: UITextView?, note: Note?) {
        guard let view = view else {
            return
        }

        let liveManager = LiveManager.shared
        if let message = liveManager.message(forNote: note) {
            let string = NSMutableAttributedString()
            let rated = note!.rating != nil
            if rated {
                if let image = UIImage(named: "ic_checked") {
                    let attachment = NSTextAttachment()
                    attachment.image = image
                    attachment.bounds = CGRect(origin: CGPoint(x: 0, y: 0), size: image.size)
                    string.append(NSAttributedString(attachment: attachment))
                    string.append(NSAttributedString(string: " "))
                }
            }
            let message = message.format()
            string.append(NSAttributedString(string: message))

            view.attributedText = string
        } else {
            view.text = "?"
        }
    }

    func valueChanged() {
        let liveManager = LiveManager.shared
        showMessage(view: valueTextView, note: liveManager.valueNote.value)
    }

    func activityChanged() {
        let liveManager = LiveManager.shared
        showMessage(view: activityTextView, note: liveManager.activityNote.value)
    }

    @IBAction func respondToStepsTouched(_ sender: AnyObject) {
        let liveManager = LiveManager.shared
        liveManager.authorizeHealthKit()
    }

    func respondToValueTouched() {
        let liveManager = LiveManager.shared
        if let note = liveManager.valueNote.value {
            let rank = note.rating?.rank ?? 0.5
            liveManager.delegate?.liveManagerAffirm(liveManager, uuid: note.uuid, type: note.type, messageKey: note.messageKey, rank: rank)
        }
    }

    func respondToActivityTouched() {
        let liveManager = LiveManager.shared
        if let note = liveManager.activityNote.value {
            let rank = note.rating?.rank ?? 0.5
            liveManager.delegate?.liveManagerAffirm(liveManager, uuid: note.uuid, type: note.type, messageKey: note.messageKey, rank: rank)
        }
    }
    
}

//
//  HomeViewController.swift
//  Live
//
//  Created by Denis Bohm on 9/9/16.
//  Copyright © 2016 Firefly Design LLC. All rights reserved.
//

import ResearchKit
import UIKit
import LiveViews

class HomeViewController: UIViewController {

    @IBOutlet var motivationalLabel: UILabel?
    @IBOutlet var stepsView: StepsView?
    @IBOutlet var stepsButton: UIButton?
    @IBOutlet var averageStepsLabel: UILabel?
    @IBOutlet var valueTextView: UITextView?
    @IBOutlet var activityTextView: UITextView?

    override func viewDidLoad() {
        super.viewDidLoad()

        let liveManager = LiveManager.shared
        liveManager.dailyStepCounts.subscribe(owner: self, observer: dailyStepCountsChanged)
        liveManager.valueMessage.subscribe(owner: self, observer: valueChanged)
        liveManager.activityMessage.subscribe(owner: self, observer: activityChanged)

        dailyStepCountsChanged()
        valueChanged()
        activityChanged()
    }

    func layout(subview: UIView?, x: CGFloat, y: inout CGFloat, width: CGFloat, height: CGFloat? = nil) {
        guard let subview = subview else {
            return
        }
        let height = height ?? subview.frame.size.height
        subview.layoutSubviews()
        subview.frame = CGRect(x: x, y: y, width: width, height: height)
        subview.layoutSubviews()
        y += height
    }

    func totalHeight(subviews: [UIView], excluding: Set<UIView> = []) -> CGFloat {
        var height: CGFloat = 0
        for subview in subviews {
            if subview.isHidden {
                continue
            }
            if excluding.contains(subview) {
                continue
            }
            height += subview.frame.size.height
        }
        return height
    }

    open override func viewDidLayoutSubviews() {
        let x: CGFloat = 0.0
        var y: CGFloat = topLayoutGuide.length
        let width = view.bounds.width
        let contentHeight = view.bounds.height - topLayoutGuide.length - bottomLayoutGuide.length
        let stepsViewHeight = contentHeight - totalHeight(subviews: view.subviews, excluding: [stepsView!])
        layout(subview: motivationalLabel, x: x, y: &y, width: width)
        layout(subview: stepsView, x: x, y: &y, width: width, height: stepsViewHeight)
        stepsButton!.frame = stepsView!.frame
        layout(subview: averageStepsLabel, x: x, y: &y, width: width)
        layout(subview: valueTextView, x: x, y: &y, width: width)
        layout(subview: activityTextView, x: x, y: &y, width: width)

// simple vertical layout
#if false
        let count = view.subviews.reduce(0) { $1.isHidden ? $0 : $0 + 1 }
        let x: CGFloat = 0.0
        var y: CGFloat = topLayoutGuide.length
        let width = view.bounds.width
        let height = (view.bounds.height - topLayoutGuide.length - bottomLayoutGuide.length) / CGFloat(count)
        for subview in view.subviews {
            if subview.isHidden {
                continue
            }
            subview.frame = CGRect(x: x, y: y, width: width, height: height)
            subview.layoutSubviews()
            subview.frame = CGRect(x: x, y: y, width: width, height: height)
            y += height
        }
#endif
    }

    func dailyStepCountsChanged() {
        let label = "Average Daily Steps: "
        let value = "Calculated On Day 7"
        let string = NSMutableAttributedString(string: "\(label)\(value)", attributes: [:])
        let range = NSRange(location: label.utf8.count, length: value.utf8.count)
        string.addAttribute(NSForegroundColorAttributeName, value: UIColor.gray, range: range)
        averageStepsLabel?.attributedText = string

        if let stepsView = stepsView, let stepsButton = stepsButton {
            if UserDefaults.standard.bool(forKey: "didAuthorizeHealthKit") {
                stepsButton.isHidden = true
                stepsView.isEnabled = true

                let liveManager = LiveManager.shared
                if liveManager.healthKitManager.authorized {
                    if let dailyStepCounts = liveManager.dailyStepCounts.value {
                        stepsView.update(startDate: dailyStepCounts.startDate, stepCounts: dailyStepCounts.stepCounts)
                    } else {
                        stepsView.update(startDate: Date(), stepCounts: [nil, nil, nil, nil, nil, nil, nil] as [Int?])
                    }
                }
            } else {
                stepsButton.isHidden = false
                stepsView.isEnabled = false
            }
        }
    }

    func showMessage(view: UITextView?, message: Message?) {
        if let view = view {
            if let message = message {
//                let checkExclusion = UIBezierPath(rect: CGRect(x: 0, y: 0, width: 100, height: 100))
//                view.textContainer.exclusionPaths = [checkExclusion]

                if let image = UIImage(named: "checked") {
                    let attributedString = NSMutableAttributedString(string: "like after")
                    let textAttachment = NSTextAttachment()
                    textAttachment.image = image
                    let attrStringWithImage = NSAttributedString(attachment: textAttachment)
                    attributedString.replaceCharacters(in: NSRange(location: 4, length: 1), with: attrStringWithImage)
                    view.attributedText = attributedString
                } else {
                    view.text = message.format()
                }
            } else {
                let text = "some message"

                if let image = UIImage(named: "checked") {
                    let attributedString = NSMutableAttributedString(string: "* ▶︎✔︎\(text)")
                    attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.orange, range: NSRange(location: 2, length: 2))
                    attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor(hue: 120.0 / 360.0, saturation: 1.0, brightness: 0.5, alpha: 1.0), range: NSRange(location: 3, length: 2))
                    let textAttachment = NSTextAttachment()
                    textAttachment.image = image
                    let attrStringWithImage = NSAttributedString(attachment: textAttachment)
                    attributedString.replaceCharacters(in: NSRange(location: 0, length: 1), with: attrStringWithImage)
                    view.attributedText = attributedString
                } else {
                    view.text = text
                }
            }
        }
    }

    func valueChanged() {
        let liveManager = LiveManager.shared
        showMessage(view: valueTextView, message: liveManager.valueMessage.value)
    }

    func activityChanged() {
        let liveManager = LiveManager.shared
        showMessage(view: activityTextView, message: liveManager.activityMessage.value)
    }

    @IBAction func respondToStepsTouched(_ sender: AnyObject) {
        UserDefaults.standard.set(true, forKey: "didAuthorizeHealthKit")

        let liveManager = LiveManager.shared
        liveManager.authorizeHealthKit()
    }

    @IBAction func respondToValueTouched(_ sender: AnyObject) {
    }

    @IBAction func respondToActivityTouched(_ sender: AnyObject) {
    }
    
}

//
//  HomeViewController.swift
//  Live
//
//  Created by Denis Bohm on 9/9/16.
//  Copyright © 2016 Firefly Design LLC. All rights reserved.
//

import UIKit
import LiveViews

class HomeViewController: TrackerViewController {

    @IBOutlet var introductionView: UIView?
    @IBOutlet var dataView: UIView?
    @IBOutlet var valueTextView: CheckboxTextView?
    @IBOutlet var activityTextView: CheckboxTextView?

    var dailyMessagesCallback: (() -> Void)? = nil

    func findChildViewController<T>() -> T? where T: UIViewController {
        if let index = (childViewControllers.index { $0 is T }) {
            return childViewControllers[index] as? T
        }
        return nil
    }

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
        
        AncestorUtility.notifyAncestorDidLoad(parent: parent, viewController: self)
    }

    func dailyStepCountsChanged() {
        let liveManager = LiveManager.shared
        if liveManager.dailyStepCounts.value != nil {
            introductionView?.isHidden = true
            dataView?.isHidden = false
        } else {
            if liveManager.didAuthorizeHealthKit {
                introductionView?.isHidden = true
                dataView?.isHidden = false
            } else {
                introductionView?.isHidden = false
                dataView?.isHidden = true
            }
        }
        
        if let viewController: HomeDataViewController = findChildViewController() {
            viewController.dailyStepCountsChanged()
        }
    }

    @IBAction func dailyMessages() {
        Tracker.sharedInstance().action(category: "Value", name: "Daily Messages")

        if let dailyMessagesCallback = dailyMessagesCallback {
            dailyMessagesCallback()
        }
    }
    
    func showMessage(view: CheckboxTextView?, note: Note?) {
        guard let view = view else {
            return
        }

        let liveManager = LiveManager.shared
        if let message = liveManager.message(forNote: note) {
            view.text = message.format()
            view.setChecked(checked: note!.rating != nil)
        } else {
            view.text = "?"
            view.setChecked(checked: false)
        }
        view.sizeFont()
    }

    func valueChanged() {
        let liveManager = LiveManager.shared
        showMessage(view: valueTextView, note: liveManager.valueNote.value)
    }

    func activityChanged() {
        let liveManager = LiveManager.shared
        showMessage(view: activityTextView, note: liveManager.activityNote.value)
    }

    @objc func respondToValueTouched() {
        let liveManager = LiveManager.shared
        if let note = liveManager.valueNote.value {
            let rank = note.rating?.rank ?? 0.5
            Tracker.sharedInstance().action(category: "Home", name: "Rank Value")
            liveManager.delegate?.liveManagerAffirm(liveManager, uuid: note.uuid, type: note.type, messageKey: note.messageKey, rank: rank)
        }
    }

    @objc func respondToActivityTouched() {
        let liveManager = LiveManager.shared
        if let note = liveManager.activityNote.value {
            let rank = note.rating?.rank ?? 0.5
            Tracker.sharedInstance().action(category: "Home", name: "Rank Activity")
            liveManager.delegate?.liveManagerAffirm(liveManager, uuid: note.uuid, type: note.type, messageKey: note.messageKey, rank: rank)
        }
    }
    
}

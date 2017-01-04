//
//  LiveTabBarController.swift
//  Live
//
//  Created by Denis Bohm on 10/20/16.
//  Copyright © 2016 Firefly Design LLC. All rights reserved.
//

import UIKit

class LiveTabBarController: UITabBarController, Ancestor, LiveManagerDelegate, ImportancePopupViewControllerDelegate, ValuesPopupViewControllerDelegate, ActivityPopupViewControllerDelegate {

    var importancePopupViewController: ImportancePopupViewController?

    var valuesPopupViewController: ValuesPopupViewController?
    var activityPopupViewController: ActivityPopupViewController?

    var uuid: String?
    var type: String?
    var messageKey: Message.Key?

    func findTabBarItem<T>() -> T? where T: UITabBarItem {
        if let items = tabBar.items {
            if let index = (items.index { $0 is T }) {
                return items[index] as? T
            }
        }
        return nil
    }

    func findViewController<T>() -> T? where T: UIViewController {
        if let index = (viewControllers?.index { $0 is T }) {
            return viewControllers?[index] as? T
        }
        return nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let liveManager = LiveManager.shared
        liveManager.delegate = self

        if !UserDefaults.standard.bool(forKey: "didShowGetStarted") {
            DispatchQueue.main.async {
                self.showGetStarted()
            }
        }

        let surveyManager = liveManager.surveyManager
        surveyManager.observable.subscribe(owner: self, observer: surveyManagerChanged)
        surveyManagerChanged()
    }

    func surveyManagerChanged() {
        if let surveyTabBarItem: SurveyTabBarItem = findTabBarItem() {
            surveyTabBarItem.hilite = LiveManager.shared.surveyManager.isScheduledDue()
        }
    }

    func ancestorDidLoad(viewController: UIViewController) {
        if let surveyIntroductionViewController = viewController as? SurveyIntroductionViewController {
            surveyIntroductionViewController.aboutCallback = selectAbout
            surveyIntroductionViewController.shareCallback = selectShare
        }
        if let surveyFormViewController = viewController as? SurveyFormViewController {
            surveyFormViewController.submitCallback = LiveManager.shared.surveyManager.submit
        }
    }

    func selectAbout() {
        if let viewController: AboutViewController = findViewController() {
            selectedViewController = viewController
        }
    }

    func selectShare() {
        if let viewController: ShareViewController = findViewController() {
            selectedViewController = viewController
        }
    }

    func importancePopupViewController(_ importancePopupViewController: ImportancePopupViewController, value: String) {
        UserDefaults.standard.set(true, forKey: "didShowGetStarted")
        
        let liveManager = LiveManager.shared
        liveManager.authorizeNotificationManager()

        var values = liveManager.orderedValues.value
        if let index = values.index(of: value) {
            values.remove(at: index)
            values.insert(value, at: 0)
        }
        liveManager.orderedValues.value = values
    }
    
    func showGetStarted() {
        if importancePopupViewController == nil {
            importancePopupViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ImportancePopupViewController") as? ImportancePopupViewController
            importancePopupViewController?.loadViewIfNeeded()
            importancePopupViewController?.delegate = self
        }
        let liveManager = LiveManager.shared
        let values = liveManager.orderedValues.value
        importancePopupViewController?.show(inView: view, values: values)
    }


    func liveManagerAffirm(_ liveManager: LiveManager, uuid: String, type: String, messageKey: Message.Key) {
        self.uuid = uuid
        self.type = type
        self.messageKey = messageKey
        if type == "Value" {
            showValues(messageKey: messageKey)
        }
        if type == "Activity" {
            showActivity(messageKey: messageKey)
        }
    }

    func showValues(messageKey: Message.Key) {
        if valuesPopupViewController == nil {
            valuesPopupViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ValuesPopupViewController") as? ValuesPopupViewController
            valuesPopupViewController?.loadViewIfNeeded()
            valuesPopupViewController?.delegate = self
        }
        let liveManager = LiveManager.shared
        guard let message = liveManager.valueMessageManager.find(messageKey: messageKey) else {
            return
        }
        valuesPopupViewController?.show(inView: view, text: message.format())
    }

    func showActivity(messageKey: Message.Key) {
        if activityPopupViewController == nil {
            activityPopupViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ActivityPopupViewController") as? ActivityPopupViewController
            activityPopupViewController?.loadViewIfNeeded()
            activityPopupViewController?.delegate = self
        }
        let liveManager = LiveManager.shared
        guard let message = liveManager.activityMessageManager.find(messageKey: messageKey) else {
            return
        }
        activityPopupViewController?.show(inView: view, text: message.format())
    }

    func affirm(rank: Double) {
        guard let uuid = uuid, let type = type, let messageKey = messageKey else {
            return
        }
        let liveManager = LiveManager.shared
        liveManager.affirm(uuid: uuid, type: type, messageKey: messageKey, rank: rank)
    }

    func valuesPopupViewController(_ valuesPopupViewController: ValuesPopupViewController, rank: Double) {
        affirm(rank: rank)
    }

    func activityPopupViewController(_ activityPopupViewController: ActivityPopupViewController, rank: Double) {
        affirm(rank: rank)
    }

}

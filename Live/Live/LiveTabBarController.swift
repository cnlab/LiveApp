//
//  LiveTabBarController.swift
//  Live
//
//  Created by Denis Bohm on 10/20/16.
//  Copyright © 2016 Firefly Design LLC. All rights reserved.
//

import UIKit

class LiveTabBarController: UITabBarController, UITabBarControllerDelegate, Ancestor, LiveManagerDelegate, IntroductionPopupViewControllerDelegate, ShareReminderPopupViewControllerDelegate, ValuesPopupViewControllerDelegate, ActivityPopupViewControllerDelegate {

    var originalViewControllers: [UIViewController] = []
    
    var introductionPopupViewController: IntroductionPopupViewController?
    var shareReminderPopupViewController: ShareReminderPopupViewController?

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

        originalViewControllers = viewControllers ?? []
        
        self.delegate = self

        let liveManager = LiveManager.shared
        liveManager.delegate = self
        liveManager.triggers.subscribe(owner: self, observer: triggersChanged)
        triggersChanged()

        checkPopups()

        let surveyManager = liveManager.surveyManager
        surveyManager.observable.subscribe(owner: self, observer: surveyManagerChanged)
        surveyManagerChanged()
    }

    func checkPopups() {
        if introductionPopupViewController != nil {
            return
        }
        let liveManager = LiveManager.shared
        if !liveManager.didShowGetStarted {
            DispatchQueue.main.async {
                self.showGetStarted()
            }
        } else {
            checkShareReminder()
        }
    }

    func checkShareReminder() {
        let liveManager = LiveManager.shared
        if !liveManager.didShowShareReminder {
            if liveManager.shareDataWithResearchers.value {
                liveManager.didShowShareReminder = true
            } else {
                if let installationDate = liveManager.installationDate {
                    if Date().timeIntervalSince(installationDate) > liveManager.reminderTimeInterval {
                        DispatchQueue.main.async {
                            self.showShareReminder()
                        }
                    }
                }
            }
        }
    }

    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        checkShareReminder()
    }

    func addDebug() {
        guard let debugViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DebugViewController") as? DebugViewController else {
            return
        }
        debugViewController.loadViewIfNeeded()
        var tabs = viewControllers ?? []
        tabs.append(debugViewController)
        setViewControllers(tabs, animated: true)
        selectedViewController = debugViewController
    }

    func surveyManagerChanged() {
        if let surveyTabBarItem: SurveyTabBarItem = findTabBarItem() {
            surveyTabBarItem.hilite = LiveManager.shared.surveyManager.isScheduledDue()
        }
    }

    func ancestorDidLoad(viewController: UIViewController) {
        if let homeViewController = viewController as? HomeViewController {
            homeViewController.dailyMessagesCallback = selectDailyMessages
        }
        if let valuesViewController = viewController as? ValuesViewController {
            valuesViewController.letsGoCallback = selectHome
        }
        if let surveyIntroductionViewController = viewController as? SurveyIntroductionViewController {
            surveyIntroductionViewController.aboutCallback = selectAbout
            surveyIntroductionViewController.shareCallback = selectShare
        }
        if let surveyFormViewController = viewController as? SurveyFormViewController {
            surveyFormViewController.submitCallback = LiveManager.shared.surveyManager.submit
        }
        if let aboutViewController = viewController as? AboutViewController {
            let swipe = UISwipeGestureRecognizer(target: self, action: #selector(self.aboutSwiped(_:)))
            swipe.direction = .right
            swipe.numberOfTouchesRequired = 1
            aboutViewController.view.addGestureRecognizer(swipe)
        }
    }

    @objc func aboutSwiped(_ gesture: UIGestureRecognizer) {
        let debugViewController: DebugViewController? = findViewController()
        if debugViewController == nil {
            addDebug()
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
    
    func selectValues() {
        if let viewController: ValuesViewController = findViewController() {
            selectedViewController = viewController
        }
    }
    
    func selectHome() {
        if let viewController: HomeViewController = findViewController() {
            selectedViewController = viewController
        }
    }
    
    func selectDailyMessages() {
        if let viewController: DailyMessagesViewController = findViewController() {
            selectedViewController = viewController
        }
    }
    
    func introductionPopupViewControllerNext(_ introductionPopupViewController: IntroductionPopupViewController) {
        let liveManager = LiveManager.shared
        liveManager.didShowGetStarted = true

        liveManager.authorizeNotificationManager()

        selectValues()
    }
    
    func showGetStarted() {
        if introductionPopupViewController == nil {
            introductionPopupViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "IntroductionPopupViewController") as? IntroductionPopupViewController
            introductionPopupViewController?.loadViewIfNeeded()
            introductionPopupViewController?.delegate = self
        }
        introductionPopupViewController?.show(inView: view)
    }

    func shareReminderPopupViewController(_ shareReminderPopupViewController: ShareReminderPopupViewController) {
        let liveManager = LiveManager.shared
        liveManager.didShowShareReminder = true

        selectShare()
    }

    func showShareReminder() {
        if shareReminderPopupViewController == nil {
            shareReminderPopupViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ShareReminderPopupViewController") as? ShareReminderPopupViewController
            shareReminderPopupViewController?.loadViewIfNeeded()
            shareReminderPopupViewController?.delegate = self
        }
        shareReminderPopupViewController?.show(inView: view)
    }

    func liveManagerAffirm(_ liveManager: LiveManager, uuid: String, type: String, messageKey: Message.Key, rank: Double) {
        self.uuid = uuid
        self.type = type
        self.messageKey = messageKey
        if type == "Value" {
            showValues(messageKey: messageKey, rank: rank)
        }
        if type == "Activity" {
            showActivity(messageKey: messageKey, rank: rank)
        }
    }

    func showValues(messageKey: Message.Key, rank: Double) {
        if valuesPopupViewController == nil {
            valuesPopupViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ValuesPopupViewController") as? ValuesPopupViewController
            valuesPopupViewController?.loadViewIfNeeded()
            valuesPopupViewController?.delegate = self
        }
        let liveManager = LiveManager.shared
        guard let message = liveManager.valueMessageManager.find(messageKey: messageKey) else {
            return
        }
        valuesPopupViewController?.show(inView: view, text: message.format(), rank: rank)
    }

    func showActivity(messageKey: Message.Key, rank: Double) {
        if activityPopupViewController == nil {
            activityPopupViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ActivityPopupViewController") as? ActivityPopupViewController
            activityPopupViewController?.loadViewIfNeeded()
            activityPopupViewController?.delegate = self
        }
        let liveManager = LiveManager.shared
        guard let message = liveManager.activityMessageManager.find(messageKey: messageKey) else {
            return
        }
        activityPopupViewController?.show(inView: view, text: message.format(), rank: rank)
    }

    func getQueryStringParameter(url: URL, parameter: String) -> String? {
        guard let components = URLComponents(string: url.absoluteString) else {
            return nil
        }
        return components.queryItems?.first(where: { $0.name == parameter })?.value
    }
    
    func liveManagerOpen(_ liveManager: LiveManager, url: URL) {
        if let studyId = getQueryStringParameter(url: url, parameter: "studyId") {
            liveManager.personalInformation.value = liveManager.personalInformation.value.bySetting(studyId: studyId)
            liveManager.shareDataWithResearchers.value = true
        }
        
        if let reminderCountParameter = getQueryStringParameter(url: url, parameter: "reminderCount") {
            if let reminderCount = Int(reminderCountParameter), reminderCount <= 4 {
                var triggers: [DateComponents] = []
                for i in 0 ..< reminderCount {
                    let hour = 9 + i * 3
                    triggers.append(DateComponents(hour: hour, minute: 0))
                }
                liveManager.triggers.value = triggers
            }
        }
    }
    
    func triggersChanged() {
        var tabs = viewControllers ?? []
        if LiveManager.shared.triggers.value.isEmpty {
            // ensure message related tabs are not present
            if let viewController: DailyMessagesViewController = findViewController() {
                if let index = tabs.index(of: viewController) {
                    tabs.remove(at: index)
                }
            }
            if let viewController: SettingsViewController = findViewController() {
                if let index = tabs.index(of: viewController) {
                    tabs.remove(at: index)
                }
            }
        } else {
            // ensure message related tabs are present
            tabs = originalViewControllers
            if let viewController: DebugViewController = findViewController() {
                tabs.append(viewController)
            }
        }
        if tabs != (viewControllers ?? []) {
            setViewControllers(tabs, animated: true)
            selectedViewController = tabs[0]
        }
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

//
//  LiveTabBarController.swift
//  Live
//
//  Created by Denis Bohm on 10/20/16.
//  Copyright © 2016 Firefly Design LLC. All rights reserved.
//

import UIKit

class LiveTabBarController: UITabBarController, LiveManagerDelegate, ValuesPopupViewControllerDelegate, ActivityPopupViewControllerDelegate {

    var valuesPopupViewController: ValuesPopupViewController?
    var activityPopupViewController: ActivityPopupViewController?

    var uuid: String?
    var type: String?
    var messageKey: Message.Key?

    override func viewDidLoad() {
        super.viewDidLoad()

        let liveManager = LiveManager.shared
        liveManager.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

//
//  ShareReminderPopupViewController.swift
//  Live
//
//  Created by Denis Bohm on 1/5/17.
//  Copyright © 2017 Firefly Design LLC. All rights reserved.
//

import UIKit

protocol ShareReminderPopupViewControllerDelegate {

    func shareReminderPopupViewController(_ shareReminderPopupViewController: ShareReminderPopupViewController)

}

class ShareReminderPopupViewController: PopupViewController {

    @IBOutlet var shareReminderView: UIView?

    var delegate: ShareReminderPopupViewControllerDelegate?

    var shareReminderViewController: ShareReminderViewController? { get { return getContainerViewController() } }

    override func viewDidLoad() {
        super.viewDidLoad()

        shareReminderViewController?.popupViewController = self
    }

    func show(inView parent: UIView) {
        super.show(inView: parent, animated: true)
    }

    func okAction() {
        closeAction()
        Tracker.sharedInstance().action(category: "Share", name: "Reminder")
        delegate?.shareReminderPopupViewController(self)
    }
    
}

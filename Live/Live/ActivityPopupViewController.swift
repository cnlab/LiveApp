//
//  ActivityPopupViewController.swift
//  Live
//
//  Created by Denis Bohm on 10/20/16.
//  Copyright © 2016 Firefly Design LLC. All rights reserved.
//

import UIKit

protocol ActivityPopupViewControllerDelegate {

    func activityPopupViewController(_ activityPopupViewController: ActivityPopupViewController, rank: Double)
    
}

class ActivityPopupViewController: PopupViewController {

    @IBOutlet var thinkView: UIView?

    var delegate: ActivityPopupViewControllerDelegate?
    
    var thinkViewController: ActivityThinkViewController? { get { return getContainerViewController() } }

    override func viewDidLoad() {
        super.viewDidLoad()

        thinkViewController?.popupViewController = self
    }

    func show(inView parent: UIView, text: String, rank: Double) {
        thinkViewController?.textView?.text = text
        thinkViewController?.rank = rank
        super.show(inView: parent, animated: true)
    }

    func saveAction() {
        closeAction()
        guard let thinkViewController = thinkViewController else {
            return
        }
        delegate?.activityPopupViewController(self, rank: thinkViewController.rank)
    }
    
}

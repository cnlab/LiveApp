//
//  ValuesPopupViewController.swift
//  Live
//
//  Created by Denis Bohm on 10/17/16.
//  Copyright © 2016 Firefly Design LLC. All rights reserved.
//

import UIKit

protocol ValuesPopupViewControllerDelegate {

    func valuesPopupViewController(_ valuesPopupViewController: ValuesPopupViewController, rank: Double)

}

class ValuesPopupViewController: PopupViewController {

    @IBOutlet var thinkView: UIView?

    var delegate: ValuesPopupViewControllerDelegate?

    var thinkViewController: ValuesThinkViewController? { get { return getContainerViewController() } }

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
        Tracker.sharedInstance().record(category: "Value", name: "rank", value: "\(thinkViewController.rank)")
        delegate?.valuesPopupViewController(self, rank: thinkViewController.rank)
    }

}

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
    @IBOutlet var rankView: UIView?

    var delegate: ActivityPopupViewControllerDelegate?
    
    var thinkViewController: ActivityThinkViewController? { get { return getContainerViewController() } }
    var rankViewController: ActivityRankViewController? { get { return getContainerViewController() } }

    override func viewDidLoad() {
        super.viewDidLoad()

        thinkViewController?.popupViewController = self
        rankViewController?.popupViewController = self
    }

    func show(inView parent: UIView, text: String) {
        thinkViewController?.textView?.text = text
        rankViewController?.textView?.text = text
        presentThink()
        super.show(inView: parent, animated: true)
    }

    func presentThink() {
        thinkView?.isHidden = false
        rankView?.isHidden = true
    }

    func presentRank() {
        thinkView?.isHidden = true
        rankView?.isHidden = false
    }

    func thinkOkAction() {
        presentRank()
    }

    func rankDoneAction() {
        closeAction()
        guard let rankViewController = rankViewController else {
            return
        }
        delegate?.activityPopupViewController(self, rank: rankViewController.rank)
    }
    
}

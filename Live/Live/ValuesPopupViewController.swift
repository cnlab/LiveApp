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
    @IBOutlet var rankView: UIView?

    var delegate: ValuesPopupViewControllerDelegate?

    var thinkViewController: ValuesThinkViewController? { get { return getContainerViewController() } }
    var rankViewController: ValuesRankViewController? { get { return getContainerViewController() } }

    override func viewDidLoad() {
        super.viewDidLoad()

        thinkViewController?.popupViewController = self
        rankViewController?.popupViewController = self
    }

    func show(inView parent: UIView, text: String, rank: Double) {
        thinkViewController?.textView?.text = text
        rankViewController?.textView?.text = text
        rankViewController?.slider?.value = Float(rank)
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
        delegate?.valuesPopupViewController(self, rank: rankViewController.rank)
    }

}

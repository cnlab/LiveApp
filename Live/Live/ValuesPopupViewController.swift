//
//  ValuesPopupViewController.swift
//  Live
//
//  Created by Denis Bohm on 10/17/16.
//  Copyright © 2016 Firefly Design LLC. All rights reserved.
//

import UIKit

class ValuesPopupViewController : PopupViewController {

    @IBOutlet var valuesThinkView: UIView?
    @IBOutlet var valuesRankView: UIView?

    func getContainerViewController<T>() -> T? {
        let viewController = childViewControllers.first(where: { $0 is T })
        return viewController as? T
    }

    var valuesThinkViewController: ValuesThinkViewController? { get { return getContainerViewController() } }
    var valuesRankViewController: ValuesRankViewController? { get { return getContainerViewController() } }

    override func viewDidLoad() {
        super.viewDidLoad()

        valuesThinkViewController?.valuesPopupViewController = self
        valuesRankViewController?.valuesPopupViewController = self
    }

    func show(inView parent: UIView, text: String) {
        valuesThinkViewController?.textView?.text = text
        valuesRankViewController?.textView?.text = text
        presentThink()
        super.show(inView: parent, animated: true)
    }

    func presentThink() {
        valuesThinkView?.isHidden = false
        valuesRankView?.isHidden = true
    }

    func presentRank() {
        valuesThinkView?.isHidden = true
        valuesRankView?.isHidden = false
    }

    func thinkOkAction() {
        presentRank()
    }

    func rankDoneAction() {
        closeAction()
    }

}

//
//  IntroductionPopupViewController.swift
//  Live
//
//  Created by Denis Bohm on 12/28/16.
//  Copyright © 2016 Firefly Design LLC. All rights reserved.
//

import UIKit

protocol IntroductionPopupViewControllerDelegate {

    func introductionPopupViewControllerNext(_ introductionPopupViewController: IntroductionPopupViewController)

}

class IntroductionPopupViewController: PopupViewController {

    @IBOutlet var introductionView: UIView?

    var delegate: IntroductionPopupViewControllerDelegate?

    var introductionPageViewController: IntroductionPageViewController? { get { return getContainerViewController() } }

    override func viewDidLoad() {
        super.viewDidLoad()

        introductionPageViewController?.popupViewController = self
        let page2 = introductionPageViewController?.pages[1] as? IntroductionPage2ViewController
        page2?.popupViewController = self
    }

    func show(inView parent: UIView) {
        super.show(inView: parent, animated: true)
    }

    func nextAction() {
        closeAction()
        delegate?.introductionPopupViewControllerNext(self)
    }

}

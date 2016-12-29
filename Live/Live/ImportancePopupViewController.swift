//
//  ImportancePopupViewController.swift
//  Live
//
//  Created by Denis Bohm on 12/28/16.
//  Copyright © 2016 Firefly Design LLC. All rights reserved.
//

import UIKit

protocol ImportancePopupViewControllerDelegate {

    func importancePopupViewController(_ importancePopupViewController: ImportancePopupViewController, value: String)

}

class ImportancePopupViewController: PopupViewController {

    @IBOutlet var importanceView: UIView?

    var delegate: ImportancePopupViewControllerDelegate?

    var importanceViewController: ImportanceViewController? { get { return getContainerViewController() } }

    override func viewDidLoad() {
        super.viewDidLoad()

        importanceViewController?.popupViewController = self
    }

    func show(inView parent: UIView, values: [String]) {
        presentImportance(values: values)
        super.show(inView: parent, animated: true)
    }

    func presentImportance(values: [String]) {
        importanceViewController?.values = values
        importanceView?.isHidden = false
    }

    func importanceOkAction() {
        closeAction()
        guard let importanceViewController = importanceViewController else {
            return
        }
        delegate?.importancePopupViewController(self, value: importanceViewController.value)
    }

}

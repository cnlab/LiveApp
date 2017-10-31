//
//  SurveyViewController.swift
//  Live
//
//  Created by Denis Bohm on 9/26/16.
//  Copyright © 2016 Firefly Design LLC. All rights reserved.
//

import UIKit

class SurveyViewController: TrackerViewController {

    @IBOutlet var introductionView: UIView?
    @IBOutlet var formView: UIView?
    @IBOutlet var nextView: UIView?

    func findChildViewController<T>() -> T? where T: UIViewController {
        if let index = (childViewControllers.index { $0 is T }) {
            return childViewControllers[index] as? T
        }
        return nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let viewController: SurveyIntroductionViewController = findChildViewController() {
            AncestorUtility.notifyAncestorDidLoad(parent: parent, viewController: viewController)
        }
        if let viewController: SurveyFormViewController = findChildViewController() {
            AncestorUtility.notifyAncestorDidLoad(parent: parent, viewController: viewController)
        }
        if let viewController: SurveyNextViewController = findChildViewController() {
            AncestorUtility.notifyAncestorDidLoad(parent: parent, viewController: viewController)
        }

        let surveyManager = LiveManager.shared.surveyManager
        surveyManager.observable.subscribe(owner: self, observer: surveyManagerChanged)
        update()
    }

    func surveyManagerChanged() {
        update()
    }

    func update() {
        let surveyManager = LiveManager.shared.surveyManager
        if surveyManager.isScheduledDue() {
            expose(view: formView)
        } else {
            if surveyManager.isScheduledFirst() {
                expose(view: introductionView)
            } else {
                expose(view: nextView)
            }
        }

        if let viewController: SurveyNextViewController = findChildViewController() {
            viewController.update()
        }
    }
    
    func expose(view: UIView?) {
        introductionView?.isHidden = view != introductionView
        formView?.isHidden = view != formView
        nextView?.isHidden = view != nextView
    }
    
}

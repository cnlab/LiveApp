//
//  SurveyViewController.swift
//  Live
//
//  Created by Denis Bohm on 9/26/16.
//  Copyright © 2016 Firefly Design LLC. All rights reserved.
//

import UIKit

class SurveyViewController: UIViewController {

    @IBOutlet var introductionView: UIView?
    @IBOutlet var formView: UIView?
    @IBOutlet var nextView: UIView?

    var surveyTabBarItem: SurveyTabBarItem? {
        get {
            return tabBarItem as? SurveyTabBarItem
        }
    }

    func findChildViewController<T>() -> T? where T: UIViewController {
        if let index = (childViewControllers.index { $0 is T }) {
            return childViewControllers[index] as? T
        }
        return nil
    }

    func notifyAncestorDidLoad(viewController child: UIViewController) {
        var ancestor = parent
        while ancestor != nil {
            let viewController = ancestor!
            if let relation = viewController as? Ancestor {
                relation.ancestorDidLoad(viewController: child)
                break
            }
            ancestor = viewController.parent
        }

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let viewController: SurveyIntroductionViewController = findChildViewController() {
            notifyAncestorDidLoad(viewController: viewController)
        }
        if let viewController: SurveyFormViewController = findChildViewController() {
            notifyAncestorDidLoad(viewController: viewController)
        }
        if let viewController: SurveyNextViewController = findChildViewController() {
            notifyAncestorDidLoad(viewController: viewController)
        }

        let surveyManager = LiveManager.shared.surveyManager
        if surveyManager.isScheduledFirst() {
            expose(view: introductionView)
        } else
        if surveyManager.isScheduledDue() {
            expose(view: formView)
        } else {
            expose(view: nextView)
        }

        expose(view: formView)
    }

    func expose(view: UIView?) {
        introductionView?.isHidden = view != introductionView
        formView?.isHidden = view != formView
        nextView?.isHidden = view != nextView
    }
    
}

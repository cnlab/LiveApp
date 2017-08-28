//
//  IntroductionPage2ViewController.swift
//  Live
//
//  Created by Denis Bohm on 8/27/17.
//  Copyright © 2017 Firefly Design LLC. All rights reserved.
//

import UIKit

class IntroductionPage2ViewController: UIViewController {

    var popupViewController: IntroductionPopupViewController? = nil
    
    @IBAction func nextAction() {
        popupViewController?.nextAction()
    }

}

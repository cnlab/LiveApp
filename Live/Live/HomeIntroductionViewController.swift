//
//  HomeIntroductionViewController.swift
//  Live
//
//  Created by Denis Bohm on 9/14/17.
//  Copyright © 2017 Firefly Design LLC. All rights reserved.
//

import UIKit

class HomeIntroductionViewController: UIViewController {
    
    @IBAction func respondToStepsTouched(_ sender: AnyObject) {
        let liveManager = LiveManager.shared
        liveManager.authorizeHealthKit()
    }
    
}

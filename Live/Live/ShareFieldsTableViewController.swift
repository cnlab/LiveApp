//
//  ShareFieldsTableViewController.swift
//  Live
//
//  Created by Denis Bohm on 12/29/16.
//  Copyright © 2016 Firefly Design LLC. All rights reserved.
//

import UIKit

class ShareFieldsTableViewController: UITableViewController {

    @IBOutlet var shareSwitch: UISwitch?

    override func viewDidLoad() {
        super.viewDidLoad()

        let liveManager = LiveManager.shared
        let share = liveManager.shareDataWithResearchers.value
        shareSwitch?.setOn(share, animated: false)
    }

    @IBAction func shareSwitchChanged() {
        let share = shareSwitch?.isOn ?? false
        Tracker.sharedInstance().event(category: "Share", name: "State", value: "\(share)")
        LiveManager.shared.shareDataWithResearchers.value = share
    }
    
}

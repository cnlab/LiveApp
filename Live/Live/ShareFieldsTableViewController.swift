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

        let share = UserDefaults.standard.bool(forKey: "shareDataWithResearchers")
        shareSwitch?.setOn(share, animated: false)
    }

    @IBAction func shareSwitchChanged() {
        let share = shareSwitch?.isOn
        UserDefaults.standard.set(share, forKey: "shareDataWithResearchers")
    }

}

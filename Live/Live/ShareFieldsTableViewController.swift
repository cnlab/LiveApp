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

        shareSwitch?.setOn(LiveManager.shared.shareDataWithResearchers, animated: false)
    }

    @IBAction func shareSwitchChanged() {
        LiveManager.shared.shareDataWithResearchers = shareSwitch?.isOn ?? false
    }

}

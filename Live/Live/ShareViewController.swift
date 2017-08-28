//
//  ShareViewController.swift
//  Live
//
//  Created by Denis Bohm on 12/29/16.
//  Copyright © 2016 Firefly Design LLC. All rights reserved.
//

import UIKit

class ShareViewController: UIViewController {

    @IBOutlet var shareNowButton: UIButton?

    open override func viewDidLayoutSubviews() {
        Layout.vertical(viewController: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let liveManager = LiveManager.shared
        liveManager.shareDataWithResearchers.subscribe(owner: self, observer: shareDataWithResearchersChanged)

        shareNowButton?.isEnabled = LiveManager.shared.shareDataWithResearchers.value
    }

    func shareDataWithResearchersChanged() {
        shareNowButton?.isEnabled = LiveManager.shared.shareDataWithResearchers.value
    }
    
    @IBAction func shareNow() {
        let liveManager = LiveManager.shared
        liveManager.cloudManager.lastModificationDate = nil
        liveManager.archive()
    }

}

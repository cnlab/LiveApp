//
//  ShareViewController.swift
//  Live
//
//  Created by Denis Bohm on 12/29/16.
//  Copyright © 2016 Firefly Design LLC. All rights reserved.
//

import UIKit

class ShareViewController: TrackerViewController {

    @IBOutlet var shareNowButton: UIButton?
    @IBOutlet var shareWarningLabel: UILabel?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let liveManager = LiveManager.shared
        liveManager.shareDataWithResearchers.subscribe(owner: self, observer: shareDataWithResearchersChanged)

        shareDataWithResearchersChanged()
    }

    func shareDataWithResearchersChanged() {
        let liveManager = LiveManager.shared
        let share = liveManager.shareDataWithResearchers.value
        shareNowButton?.isEnabled = share
        
        let studyId = liveManager.personalInformation.value.studyId ?? ""
        shareWarningLabel?.isHidden = (studyId == "") || share;
    }
    
    @IBAction func shareNow() {
        Tracker.sharedInstance().action(category: "Share", name: "Now")
        let liveManager = LiveManager.shared
        liveManager.cloudManager.lastModificationDate = nil
        liveManager.archive()
    }

}

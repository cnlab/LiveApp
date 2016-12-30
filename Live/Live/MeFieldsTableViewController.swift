//
//  MeFieldsTableViewController.swift
//  Live
//
//  Created by Denis Bohm on 12/29/16.
//  Copyright © 2016 Firefly Design LLC. All rights reserved.
//

import UIKit

class MeFieldsTableViewController: UITableViewController {

    @IBOutlet var ageTextField: UITextField?
    @IBOutlet var zipCodeTextField: UITextField?
    @IBOutlet var commentTextField: UITextField?
    @IBOutlet var genderSegmentedControl: UISegmentedControl?
    @IBOutlet var weightButton: UIButton?
    @IBOutlet var weightPerceptionButton: UIButton?
    @IBOutlet var heightButton: UIButton?

    func select(segmentedControl: UISegmentedControl?, title: String?) {
        guard let segmentedControl = segmentedControl, let title = title else {
            return
        }
        for i in 0 ..< segmentedControl.numberOfSegments {
            let segmentTitle = segmentedControl.titleForSegment(at: i)
            if segmentTitle == title {
                segmentedControl.selectedSegmentIndex = i
                return
            }
        }
    }

    func title(segmentedControl: UISegmentedControl?) -> String? {
        guard let segmentedControl = segmentedControl else {
            return nil
        }
        return segmentedControl.titleForSegment(at: segmentedControl.selectedSegmentIndex)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        ageTextField?.text = UserDefaults.standard.string(forKey: "userAge")
        zipCodeTextField?.text = UserDefaults.standard.string(forKey: "userZipCode")
        commentTextField?.text = UserDefaults.standard.string(forKey: "userComment")

        if let title = UserDefaults.standard.string(forKey: "userGenger") {
            select(segmentedControl: genderSegmentedControl, title: title)
        }
    }

    @IBAction func fieldChanged() {
        UserDefaults.standard.set(ageTextField?.text, forKey: "userAge")
        UserDefaults.standard.set(zipCodeTextField?.text, forKey: "userZipCode")
        UserDefaults.standard.set(commentTextField?.text, forKey: "userComment")

        if let title = title(segmentedControl: genderSegmentedControl) {
            UserDefaults.standard.set(title, forKey: "userGenger")
        }
    }
    
}

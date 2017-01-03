//
//  MeFieldsTableViewController.swift
//  Live
//
//  Created by Denis Bohm on 12/29/16.
//  Copyright © 2016 Firefly Design LLC. All rights reserved.
//

import UIKit

class MeFieldsTableViewController: UITableViewController {

    let weightPerceptionValues = ["perception...", "about right", "heavier than I would like", "lighter than I would like"]

    @IBOutlet var ageTextField: UITextField?
    @IBOutlet var zipCodeTextField: UITextField?
    @IBOutlet var commentTextField: UITextField?
    @IBOutlet var genderSegmentedControl: UISegmentedControl?
    @IBOutlet var weightTextField: UITextField?
    @IBOutlet var weightPerceptionButton: UIButton?
    @IBOutlet var heightButton: UIButton?

    var pickerPopupViewController: PickerPopupViewController? = nil

    func ensurePicker() {
        if pickerPopupViewController == nil {
            pickerPopupViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PickerPopupViewController") as? PickerPopupViewController
            pickerPopupViewController?.loadViewIfNeeded()
        }
    }

    func perceivedWeightChanged() {
        if let selections = pickerPopupViewController?.pickerViewController?.selections {
            if selections.count == 1 {
                if let weightPerception = selections[0] as? String {
                    weightPerceptionButton?.setTitle(weightPerception, for: .normal)
                    UserDefaults.standard.set(weightPerception, forKey: "userWeightPerception")
                    return
                }
            }
        }
        weightPerceptionButton?.setTitle(weightPerceptionValues[0], for: .normal)
        UserDefaults.standard.removeObject(forKey: "userHeight")
    }

    @IBAction func changePerceivedWeight() {
        ensurePicker()
        guard let meViewController = parent as? MeViewController else {
            return
        }
        pickerPopupViewController?.show(inView: meViewController.view, values: weightPerceptionValues, value: weightPerceptionButton?.titleLabel?.text, action: perceivedWeightChanged)
    }

    func format(height: Int) -> String {
        let feet = height / 12
        let inches = height - feet * 12
        let text: String
        if feet == 0 {
            text = "-' --\""
        } else {
            text = "\(feet)' \(inches)\""
        }
        return text
    }

    func heightChanged() {
        if let selections = pickerPopupViewController?.pickerViewController?.selections {
            if selections.count == 2 {
                if let feet = selections[0] as? Int, let inches = selections[1] as? Int {
                    let height = feet * 12 + inches
                    heightButton?.setTitle(format(height: height), for: .normal)
                    UserDefaults.standard.set(height, forKey: "userHeight")
                    return
                }
            }
        }
        heightButton?.setTitle(format(height: 0), for: .normal)
        UserDefaults.standard.removeObject(forKey: "userHeight")
    }

    @IBAction func changeHeight() {
        ensurePicker()
        guard let meViewController = parent as? MeViewController else {
            return
        }
        let height = UserDefaults.standard.integer(forKey: "userHeight")
        let feet = height / 12
        let inches = height - feet * 12
        pickerPopupViewController?.show(inView: meViewController.view, feet: feet, inches: inches, action: heightChanged)
    }

    func select(segmentedControl: UISegmentedControl?, title: String?) {
        if let segmentedControl = segmentedControl, let title = title {
            for i in 0 ..< segmentedControl.numberOfSegments {
                let segmentTitle = segmentedControl.titleForSegment(at: i)
                if segmentTitle == title {
                    segmentedControl.selectedSegmentIndex = i
                    return
                }
            }
        }
        segmentedControl?.selectedSegmentIndex = 0
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
        weightTextField?.text = UserDefaults.standard.string(forKey: "userWeight")
        zipCodeTextField?.text = UserDefaults.standard.string(forKey: "userZipCode")
        commentTextField?.text = UserDefaults.standard.string(forKey: "userComment")

        select(segmentedControl: genderSegmentedControl, title: UserDefaults.standard.string(forKey: "userGenger"))

        let weightPerception = UserDefaults.standard.string(forKey: "userWeightPerception")
        weightPerceptionButton?.setTitle(weightPerception ?? weightPerceptionValues[0], for: .normal)

        let height = UserDefaults.standard.integer(forKey: "userHeight")
        heightButton?.setTitle(format(height: height), for: .normal)
    }

    @IBAction func fieldChanged() {
        UserDefaults.standard.set(ageTextField?.text, forKey: "userAge")
        UserDefaults.standard.set(weightTextField?.text, forKey: "userWeight")
        UserDefaults.standard.set(zipCodeTextField?.text, forKey: "userZipCode")
        UserDefaults.standard.set(commentTextField?.text, forKey: "userComment")

        if let title = title(segmentedControl: genderSegmentedControl) {
            UserDefaults.standard.set(title, forKey: "userGenger")
        }
    }
    
}

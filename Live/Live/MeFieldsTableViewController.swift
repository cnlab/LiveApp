//
//  MeFieldsTableViewController.swift
//  Live
//
//  Created by Denis Bohm on 12/29/16.
//  Copyright © 2016 Firefly Design LLC. All rights reserved.
//

import UIKit

class MeFieldsTableViewController: UITableViewController, UITextFieldDelegate {

    let weightPerceptionValues = ["perception...", "about right", "heavier than I would like", "lighter than I would like"]

    @IBOutlet var ageTextField: UITextField?
    @IBOutlet var zipCodeTextField: UITextField?
    @IBOutlet var commentTextField: UITextField?
    @IBOutlet var genderSegmentedControl: UISegmentedControl?
    @IBOutlet var weightTextField: UITextField?
    @IBOutlet var weightPerceptionButton: UIButton?
    @IBOutlet var heightButton: UIButton?

    var pickerPopupViewController: PickerPopupViewController? = nil

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }

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
                    fieldChanged()
                }
            }
        }
    }

    @IBAction func changePerceivedWeight() {
        ensurePicker()
        guard let meViewController = parent as? MeViewController else {
            return
        }
        pickerPopupViewController?.show(inView: meViewController.view, values: weightPerceptionValues, value: weightPerceptionButton?.title(for: .normal), action: perceivedWeightChanged)
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

    func parse(height: String?) -> Int? {
        guard let height = height else {
            return nil
        }
        let tokens = height.components(separatedBy: " ")
        if tokens.count != 2 {
            return nil
        }
        let token0 = tokens[0]
        let feet = Int(token0.substring(with: token0.startIndex ..< token0.index(before: token0.endIndex))) ?? 0
        let token1 = tokens[1]
        let inches = Int(token1.substring(with: token1.startIndex ..< token1.index(before: token1.endIndex))) ?? 0
        return feet * 12 + inches
    }

    func heightChanged() {
        if let selections = pickerPopupViewController?.pickerViewController?.selections {
            if selections.count == 2 {
                if let feet = selections[0] as? Int, let inches = selections[1] as? Int {
                    let height = feet * 12 + inches
                    heightButton?.setTitle(format(height: height), for: .normal)
                    fieldChanged()
                }
            }
        }
    }

    @IBAction func changeHeight() {
        ensurePicker()
        guard let meViewController = parent as? MeViewController else {
            return
        }
        let height = LiveManager.shared.personalInformation.value.height ?? 0
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

    @IBAction func genderChanged() {
        UIApplication.shared.sendAction(#selector(UIApplication.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    func title(segmentedControl: UISegmentedControl?) -> String? {
        guard let segmentedControl = segmentedControl else {
            return nil
        }
        return segmentedControl.titleForSegment(at: segmentedControl.selectedSegmentIndex)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        LiveManager.shared.personalInformation.subscribe(owner: self, observer: personalInformationChanged)
        update()
    }

    func personalInformationChanged() {
        update()
    }

    func update() {
        let personalInformation = LiveManager.shared.personalInformation.value
        if let age = personalInformation.age {
            ageTextField?.text = "\(age)"
        } else {
            ageTextField?.text = ""
        }
        if let gender = personalInformation.gender {
            select(segmentedControl: genderSegmentedControl, title: gender)
        } else {
            genderSegmentedControl?.selectedSegmentIndex = 0
        }
        if let weight = personalInformation.weight {
            weightTextField?.text = "\(weight)"
        } else {
            weightTextField?.text = ""
        }
        if let weightPerception = personalInformation.weightPerception {
            weightPerceptionButton?.setTitle(weightPerception, for: .normal)
        } else {
            weightPerceptionButton?.setTitle(weightPerceptionValues[0], for: .normal)
        }
        if let height = personalInformation.height {
            heightButton?.setTitle(format(height: height), for: .normal)
        } else {
            heightButton?.setTitle(format(height: 0), for: .normal)
        }
        if let zipCode = personalInformation.zipCode {
            zipCodeTextField?.text = zipCode
        } else {
            zipCodeTextField?.text = ""
        }
        if let comment = personalInformation.comment {
            commentTextField?.text = comment
        } else {
            commentTextField?.text = ""
        }
    }

    @IBAction func fieldChanged() {
        let age = Int(ageTextField?.text ?? "")
        let gender = title(segmentedControl: genderSegmentedControl)
        let weight = Int(weightTextField?.text ?? "")
        let weightPerception = weightPerceptionButton?.title(for: .normal) ?? ""
        let height = parse(height: heightButton?.title(for: .normal))
        let zipCode = zipCodeTextField?.text
        let comment = commentTextField?.text
        LiveManager.shared.personalInformation.value = PersonalInformation(age: age, gender: gender, weight: weight, weightPerception: weightPerception, height: height, zipCode: zipCode, comment: comment)
    }
    
}

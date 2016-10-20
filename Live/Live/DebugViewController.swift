//
//  DebugViewController.swift
//  Live
//
//  Created by Denis Bohm on 10/16/16.
//  Copyright © 2016 Firefly Design LLC. All rights reserved.
//

import UIKit

class DebugViewController: UIViewController {

    @IBOutlet var textView: UITextView? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(_ animated: Bool) {
        guard let textView = textView else {
            return
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd"

        var text = ""
        let liveManager = LiveManager.shared
        let schedule = liveManager.schedule
        for day in schedule.days {
            for note in day.notes {
                let date = dateFormatter.string(from: day.date)
                text += "\(date) \(note.status) \(note.type) \(note.messageKey.group) \(note.messageKey.identifier) \(note.uuid)\n"
            }
        }

        textView.text = text
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

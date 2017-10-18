//
//  DailyMessagesViewController.swift
//  Live
//
//  Created by Denis Bohm on 10/9/17.
//  Copyright © 2017 Firefly Design LLC. All rights reserved.
//

import UIKit

class DailyMessagesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var dateFormatter: DateFormatter = DateFormatter()

    struct DailyMessage {
        let uuid: String
        let date: String
        let text: String
        let rated: Bool
    }
    
    @IBOutlet var tableView: UITableView!
    
    let reuseIdentifier = "DailyMessageCell"
    
    var dailyMessages: [DailyMessage] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateFormatter.dateFormat = "EEEE, MMMM d, yyyy"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let today = Calendar.current.dateComponents([.year, .month, .day], from: Date())

        dailyMessages = []
        let liveManager = LiveManager.shared
        for day in liveManager.schedule.completedDays().reversed() {
            for note in day.notes.reversed() {
                if note.deleted {
                    continue
                }
                let date: String
                let moment = day.moment
                if (moment.year == today.year) && (moment.month == today.month) && (moment.day == today.day) {
                    date = "today"
                } else {
                    if let when = Calendar.current.date(from: DateComponents(year: moment.year, month: moment.month, day: moment.day)) {
                        date = dateFormatter.string(from: when)
                    } else {
                        date = "***"
                    }
                }
                let text: String
                if let message = liveManager.message(forNote: note) {
                    text = message.format()
                } else {
                    text = "***"
                }
                let rated = note.rating != nil
                dailyMessages.append(DailyMessage(uuid: note.uuid, date: date, text: text, rated: rated))
            }
        }
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dailyMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dailyMessage = self.dailyMessages[indexPath.row]
        let cell: DailyMessagesTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as! DailyMessagesTableViewCell!
        cell.dateLabel?.text = dailyMessage.date
        cell.checkboxTextView?.tappedCallback = {}
        cell.checkboxTextView?.text = dailyMessage.text
        cell.checkboxTextView?.setChecked(checked: dailyMessage.rated)
        cell.checkboxTextView?.image = UIImage(named: "ic_checked")
        cell.checkboxTextView?.sizeFontToFitText();
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let row = indexPath.row
            let dailyMessage = dailyMessages.remove(at: row)
            let liveManager = LiveManager.shared
            liveManager.delete(uuid: dailyMessage.uuid)
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

}

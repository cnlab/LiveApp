//
//  DebugViewController.swift
//  Live
//
//  Created by Denis Bohm on 10/16/16.
//  Copyright © 2016 Firefly Design LLC. All rights reserved.
//

import UIKit
import MessageUI

class DebugViewController: UIViewController, MFMailComposeViewControllerDelegate {

    @IBOutlet var textView: UITextView? = nil

    override func viewDidAppear(_ animated: Bool) {
        if let data = try? Data(contentsOf: LiveManager.shared.archivePath, options: []) {
            textView?.text = String(data: data, encoding: .utf8)
        }
    }

    @IBAction func resetSchedule() {
        LiveManager.shared.resetSchedule()
    }

    @IBAction func advanceTime() {
        let liveManager = LiveManager.shared
        liveManager.surveyManager.changeDueDateToNow()
        guard let installationDate = liveManager.installationDate else {
            return
        }
        let date = Date().addingTimeInterval(-liveManager.reminderTimeInterval)
        if date < installationDate {
            liveManager.installationDate = date
        }
    }

    @IBAction func send() {
        sendMail(recipients: ["denis@fireflydesign.com"])
    }

    func alert(message: String) {
        let alertController = UIAlertController(title: "Mail Result", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }

    func sendMail(recipients: [String]) {
        if !MFMailComposeViewController.canSendMail() {
            alert(message: "No mail account found.")
        }

        if let mailCompose: MFMailComposeViewController = MFMailComposeViewController() as MFMailComposeViewController? {
            mailCompose.mailComposeDelegate = self
            mailCompose.setToRecipients(recipients)
            mailCompose.setSubject("Live Active Debug")
            mailCompose.setMessageBody("See attachment for details.", isHTML: false)
            let path = LiveManager.shared.archivePath
            if let data = try? Data(contentsOf: path, options: []) {
                let fileName = path.lastPathComponent
                mailCompose.addAttachmentData(data, mimeType: "text/plain", fileName: fileName)
            }
            present(mailCompose, animated: true, completion: nil)
        } else {
            alert(message: "Mail is not available.")
        }
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case .cancelled:
            alert(message: "Mail was cancelled.")
        case .saved:
            alert(message: "Mail was saved.")
        case .sent:
            alert(message: "Mail was sent.")
        case .failed:
            alert(message: "Sending mail failed: \(String(describing: error)).")
        }
        dismiss(animated: false, completion: nil)
    }

}

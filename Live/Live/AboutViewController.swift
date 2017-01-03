//
//  AboutViewController.swift
//  Live
//
//  Created by Denis Bohm on 12/29/16.
//  Copyright © 2016 Firefly Design LLC. All rights reserved.
//

import UIKit
import MessageUI

class AboutViewController: UIViewController, UITextViewDelegate, MFMailComposeViewControllerDelegate {

    @IBOutlet var textView: UITextView?
    @IBOutlet var versionLabel: UILabel?

    override func viewDidLoad() {
        super.viewDidLoad()

        if let info = Bundle.main.infoDictionary {
            let name = info["CFBundleDisplayName"] as? String ?? "Live Active!"
            let version = info["CFBundleShortVersionString"] as? String ?? "0.0"
            let build = info["CFBundleVersion"] as? String ?? "0"

            versionLabel?.text = "\(name) Version \(version) Build \(build)"
        }
    }

    open override func viewDidLayoutSubviews() {
        Layout.vertical(viewController: self, flexibleView: textView)
    }

    func alert(message: String) {
        let alertController = UIAlertController(title: "Mail Result", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }

    func mailtoProperties(URL: URL) -> [String : String] {
        var properties: [String : String] = [:]
        let components = NSURLComponents(url: URL, resolvingAgainstBaseURL: false)
        if let path = components?.path {
            properties["recipient"] = path
        }
        let _ = components?.queryItems?.reduce([:], { (_, item) -> [String: String] in
                properties[item.name] = item.value
                return properties
            })
        return properties
    }

    func shouldInteractWith(textView: UITextView, URL: URL) -> Bool {
        if URL.scheme == "mailto" {
            let properties = mailtoProperties(URL: URL)
            let recipient = properties["recipient"]
            sendMail(recipients: [recipient!])
            return false
        }
        return true
    }

    @available(iOS 10.0, *)
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return shouldInteractWith(textView: textView, URL: URL)
    }

    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        return shouldInteractWith(textView: textView, URL: URL)
    }

    func sendMail(recipients: [String]) {
        if !MFMailComposeViewController.canSendMail() {
            alert(message: "No mail account found.")
        }

        if let mailCompose: MFMailComposeViewController = MFMailComposeViewController() as MFMailComposeViewController? {
            mailCompose.mailComposeDelegate = self
            mailCompose.setSubject("Live Active Question")
            mailCompose.setMessageBody("Help!", isHTML: false)
            mailCompose.setToRecipients(recipients)
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
                alert(message: "Sending mail failed: \(error).")
        }
        dismiss(animated: false, completion: nil)
    }

}

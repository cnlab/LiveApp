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

    override func viewDidAppear(_ animated: Bool) {
        if let data = try? Data(contentsOf: LiveManager.shared.archivePath, options: []) {
            textView?.text = String(data: data, encoding: .utf8)
        }
    }

}

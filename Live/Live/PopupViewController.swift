//
//  PopupViewController.swift
//  Live
//
//  Created by Denis Bohm on 10/17/16.
//  Copyright © 2016 Firefly Design LLC. All rights reserved.
//

import UIKit

class PopupViewController: UIViewController {

    @IBOutlet var contentView: UIView?

    override func viewDidLoad() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.6)

        if let contentView = contentView {
            contentView.layer.cornerRadius = 5
            contentView.layer.shadowOpacity = 0.8
            contentView.layer.shadowOffset = CGSize(width: 0, height: 0)
        }

        super.viewDidLoad()
    }

    func showAnimate() {
        view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        view.alpha = 0
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1
            self.view.transform = CGAffineTransform(scaleX: 1, y: 1)
        })
    }
 
    func removeAnimate() {
        UIView.animate(withDuration: 0.25,
                       animations: {
                        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                        self.view.alpha = 0.0
            },
                       completion: {
                        (finished: Bool) in
                        if finished {
                            self.view.removeFromSuperview()
                        }
            }
        )
    }

    @IBAction func closeAction() {
        removeAnimate()
    }

    func show(inView parent: UIView, animated: Bool) {
        parent.addSubview(self.view)
        if animated {
            showAnimate()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

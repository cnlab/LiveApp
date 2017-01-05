//
//  Ancestor.swift
//  Live
//
//  Created by Denis Bohm on 1/3/17.
//  Copyright © 2017 Firefly Design LLC. All rights reserved.
//

import UIKit

protocol Ancestor {

    func ancestorDidLoad(viewController: UIViewController)

}

class AncestorUtility {

    static func notifyAncestorDidLoad(parent: UIViewController?, viewController child: UIViewController) {
        var ancestor = parent
        while ancestor != nil {
            let viewController = ancestor!
            if let relation = viewController as? Ancestor {
                relation.ancestorDidLoad(viewController: child)
                break
            }
            ancestor = viewController.parent
        }

    }
    
}

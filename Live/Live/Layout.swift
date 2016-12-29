//
//  Layout.swift
//  Live
//
//  Created by Denis Bohm on 12/29/16.
//  Copyright © 2016 Firefly Design LLC. All rights reserved.
//

import UIKit

class Layout {

    static func place(subview: UIView?, x: CGFloat, y: inout CGFloat, width: CGFloat, height: CGFloat? = nil) {
        guard let subview = subview else {
            return
        }
        let height = height ?? subview.frame.size.height
        subview.layoutSubviews()
        subview.frame = CGRect(x: x, y: y, width: width, height: height)
        subview.layoutSubviews()
        y += height
    }

    static func totalHeight(subviews: [UIView], excluding: Set<UIView> = []) -> CGFloat {
        var height: CGFloat = 0
        for subview in subviews {
            if subview.isHidden {
                continue
            }
            if excluding.contains(subview) {
                continue
            }
            height += subview.frame.size.height
        }
        return height
    }

    static func vertical(viewController: UIViewController, flexibleView: UIView? = nil) {
        guard let view = viewController.view else {
            return
        }

        let topMargin = viewController.topLayoutGuide.length
        let bottomMargin = viewController.bottomLayoutGuide.length
        let x: CGFloat = 0.0
        var y: CGFloat = viewController.topLayoutGuide.length
        let width = viewController.view.bounds.width
        let contentHeight = view.bounds.height - topMargin - bottomMargin

        let flexibleHeight: CGFloat?
        if let flexibleView = flexibleView {
            flexibleHeight = contentHeight - Layout.totalHeight(subviews: view.subviews, excluding: [flexibleView])
        } else {
            flexibleHeight = nil
        }

        for subview in view.subviews {
            Layout.place(subview: subview, x: x, y: &y, width: width, height: subview == flexibleView ? flexibleHeight : nil)
        }
    }


}

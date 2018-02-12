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

    static func totalHeight(subviews: [UIView], excluding: Set<UIView> = [], spacing: CGFloat = 4.0) -> CGFloat {
        var height: CGFloat = 0
        for subview in subviews {
            if subview.isHidden {
                break
            }
            if excluding.contains(subview) {
                continue
            }
            if height > 0 {
                height += spacing
            }
            height += subview.frame.size.height
        }
        return height
    }

    static func vertical(viewController: UIViewController, flexibleView: UIView? = nil, insets: UIEdgeInsets = UIEdgeInsets(top: 8.0, left: 16.0, bottom: 8.0, right: 16.0), spacing: CGFloat = 8.0) {
        guard let view = viewController.view else {
            return
        }

        var fullInsets = insets
        fullInsets.top += viewController.topLayoutGuide.length
        fullInsets.bottom += viewController.bottomLayoutGuide.length

        vertical(viewController: viewController, view: view, flexibleView: flexibleView, insets: fullInsets, spacing: spacing)
    }

    static func vertical(viewController: UIViewController, view: UIView, flexibleView: UIView? = nil, insets: UIEdgeInsets = UIEdgeInsets(top: 8.0, left: 16.0, bottom: 8.0, right: 16.0), spacing: CGFloat = 8.0) {
        let x: CGFloat = insets.left
        let y: CGFloat = insets.top
        let width = view.bounds.width - insets.right - insets.left
        let contentHeight = view.bounds.height - insets.top - insets.bottom
        let flexibleHeight: CGFloat?
        if let flexibleView = flexibleView {
            flexibleHeight = contentHeight - Layout.totalHeight(subviews: view.subviews, excluding: [flexibleView], spacing: spacing)
        } else {
            flexibleHeight = nil
        }

        var cy = y
        for subview in view.subviews {
            if subview.isHidden {
                break
            }
            Layout.place(subview: subview, x: x, y: &cy, width: width, height: subview == flexibleView ? flexibleHeight : nil)
            cy += spacing
        }
    }

    static func vertical(viewController: UIViewController, view: UIView, flexibleViews: Set<UIView> = [], insets: UIEdgeInsets = UIEdgeInsets(top: 8.0, left: 16.0, bottom: 8.0, right: 16.0), spacing: CGFloat = 8.0) {
        let x: CGFloat = insets.left
        let y: CGFloat = insets.top
        let width = view.bounds.width - insets.right - insets.left
        let contentHeight = view.bounds.height - insets.top - insets.bottom
        let totalFlexibleHeight = contentHeight - Layout.totalHeight(subviews: view.subviews, excluding: flexibleViews, spacing: spacing)
        let flexibleHeight = totalFlexibleHeight / CGFloat(flexibleViews.count)
        
        var cy = y
        for subview in view.subviews {
            if subview.isHidden {
                break
            }
            Layout.place(subview: subview, x: x, y: &cy, width: width, height: flexibleViews.contains(subview) ? flexibleHeight : nil)
            cy += spacing
        }
    }
    
}

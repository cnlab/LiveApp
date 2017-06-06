//
//  ImageLabelView.swift
//  Live
//
//  Created by Denis Bohm on 6/5/17.
//  Copyright © 2017 Firefly Design LLC. All rights reserved.
//

import UIKit

@IBDesignable open class ImageLabelView: UIView {

    @IBInspectable open var topInset: CGFloat = 0.0
    @IBInspectable open var leftInset: CGFloat = 0.0
    @IBInspectable open var bottomInset: CGFloat = 0.0
    @IBInspectable open var rightInset: CGFloat = 0.0
    open var insets: UIEdgeInsets {
        get {
            return UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        }
    }

    @IBInspectable open var outlineColor: UIColor?
    @IBInspectable open var highlightColor: UIColor?
    @IBInspectable open var fontSize: CGFloat = 26.0
    @IBInspectable open var textColor: UIColor?
    @IBInspectable open var textLeftInset: CGFloat = 8.0
    @IBInspectable open var imageLeftInset: CGFloat = 40.0
    @IBInspectable open var imageWidth: CGFloat = 32.0

    @IBInspectable open var margin: CGFloat = 8.0
    @IBInspectable open var text: String?
    @IBInspectable open var image: UIImage?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setDefaults()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setDefaults()
    }

    open func setDefaults() {
    }

    override open func draw(_ rect: CGRect) {
        super.draw(rect)

        let font = UIFont.systemFont(ofSize: fontSize)
        let style = NSMutableParagraphStyle()
        style.setParagraphStyle(NSParagraphStyle.default)
        style.alignment = NSTextAlignment.left

        let content = CGRect(x: insets.left, y: insets.top, width: frame.size.width - insets.left - insets.right, height: frame.size.height - insets.top - insets.bottom)

        var highlightRect = content
        highlightRect.origin.x += margin
        highlightRect.size.width -= 2.0 * margin
        let highlight = UIBezierPath(roundedRect: highlightRect, byRoundingCorners: [.topLeft, .topRight, .bottomLeft, .bottomRight], cornerRadii: CGSize(width: 4.0, height: 4.0))
        if let highlightColor = self.highlightColor {
            highlightColor.setFill()
            highlight.fill()
        }
        if let outlineColor = self.outlineColor {
            outlineColor.setStroke()
            highlight.stroke()
        }

        if let image = self.image {
            var point = content.origin
            point.x += imageLeftInset
            point.x += (imageWidth - image.size.width) / 2.0
            point.y += (content.size.height - image.size.height) / 2.0
            image.draw(at: point)
        }

        if let text = self.text, let textColor = self.textColor {
            let point = CGPoint(x: content.origin.x + imageLeftInset + imageWidth + textLeftInset, y: content.origin.y + (content.size.height - font.lineHeight) / 2.0)
            let attributes: [String : Any] = [NSFontAttributeName: font, NSParagraphStyleAttributeName: style, NSForegroundColorAttributeName: textColor]
            text.draw(at: point, withAttributes: attributes)
        }
    }
    
}

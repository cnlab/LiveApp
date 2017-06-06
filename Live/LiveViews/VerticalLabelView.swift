//
//  VerticalLabelView.swift
//  Live
//
//  Created by Denis Bohm on 6/5/17.
//  Copyright © 2017 Firefly Design LLC. All rights reserved.
//

import UIKit

@IBDesignable open class VerticalLabelView: UIView {

    @IBInspectable open var fontSize: CGFloat = 13.0
    @IBInspectable open var textColor: UIColor = UIColor.black
    @IBInspectable open var text: String?
    @IBInspectable open var angle: CGFloat = -90.0
    @IBInspectable open var alignRight: Bool = false

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

        guard let text = self.text else {
            return
        }

        let font = UIFont.systemFont(ofSize: fontSize)
        let attributes: [String : Any] = [NSFontAttributeName: font, NSForegroundColorAttributeName: textColor]
        let textSize = text.size(attributes: attributes)
        let context = UIGraphicsGetCurrentContext()!
        context.saveGState()
        let center = CGPoint(x: frame.size.width / 2.0, y: frame.size.height / 2.0)
        context.translateBy(x: center.x, y: center.y)
        context.rotate(by: angle * .pi / 180.0)
        let x = alignRight ? frame.size.height / 2.0 - textSize.width : -frame.size.height / 2.0
        context.translateBy(x: x, y: -textSize.height / 2.0)
//        context.translateBy(x: -textSize.width / 2.0, y: -textSize.height / 2.0)
        text.draw(at: CGPoint(x: 0.0, y: 0.0), withAttributes: attributes)
        context.restoreGState()
    }
    
}

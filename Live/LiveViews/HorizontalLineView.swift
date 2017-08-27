//
//  HorizontalLineView.swift
//  Live
//
//  Created by Denis Bohm on 8/25/17.
//  Copyright © 2017 Firefly Design LLC. All rights reserved.
//

import Foundation

@IBDesignable open class HorizontalLineView: UIView {
    
    @IBInspectable open var lineColor: UIColor = UIColor.black
    
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
        
        lineColor.setFill()
        let line = UIBezierPath(rect: CGRect(x: 0.0, y: 0.0, width: frame.size.width, height: frame.size.height))
        line.fill()
    }
    
}

//
//  CheckboxTextView.swift
//  Live
//
//  Created by Denis Bohm on 8/29/17.
//  Copyright © 2017 Firefly Design LLC. All rights reserved.
//

import Foundation

@IBDesignable open class CheckboxTextView: UITextView {
    
    @IBInspectable open var image: UIImage?
    @IBInspectable var isChecked: Bool = false
    
    public var tappedCallback: ((Void) -> Void)? = nil

    let tapGestureRecognizer = UITapGestureRecognizer()

    public override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    func initialize() {
        isEditable = false
        isScrollEnabled = false
        
        textContainerInset = UIEdgeInsets.zero
        textContainer.lineBreakMode = .byTruncatingTail

        gestureRecognizers = []
        tapGestureRecognizer.numberOfTapsRequired = 1
        tapGestureRecognizer.addTarget(self, action: #selector(tapped(_:)))
        addGestureRecognizer(tapGestureRecognizer)
        
        text = "Sample text that is a really long line of text to see what happens when the text is too long to fit within the space available to the text region"
    }
    
    func tapped(_ sender: UITapGestureRecognizer) {
        if let tappedCallback = tappedCallback {
            tappedCallback()
        } else {
            setChecked(checked: !isChecked)
        }
    }
    
    open func setChecked(checked: Bool) {
        isChecked = checked
        setNeedsLayout()
    }
    
    func updateExclusionPaths() {
        if let font = font {
            textContainer.maximumNumberOfLines = max(Int(contentSize.height / font.lineHeight), 1)
        } else {
            textContainer.maximumNumberOfLines = 1
        }
        
        if isChecked, let image = image {
            textContainer.exclusionPaths = [UIBezierPath(rect: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))]
        } else {
            textContainer.exclusionPaths = []
        }
    }
    
    override open func layoutSubviews() {
        updateExclusionPaths()
        super.layoutSubviews()
        setNeedsDisplay()
    }
    
    override open func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if isChecked, let image = image {
            image.draw(at: CGPoint(x: 0, y: 0))
        }
    }

}

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
    @IBInspectable open var isChecked: Bool = false
    @IBInspectable open var targetFont: UIFont? = nil
    @IBInspectable open var minimumFontSize: CGFloat = 10.0
    @IBInspectable open var sizeFontToFitText: Bool = false
    
    public var tappedCallback: (() -> Void)? = nil

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
        textContainer.maximumNumberOfLines = 0
        
        gestureRecognizers = []
        tapGestureRecognizer.numberOfTapsRequired = 1
        tapGestureRecognizer.addTarget(self, action: #selector(tapped(_:)))
        addGestureRecognizer(tapGestureRecognizer)
        
        text = "Sample text that is a really long line of text to see what happens when the text is too long to fit within the space available to the text region"
        targetFont = UIFont.systemFont(ofSize: UIFont.systemFontSize)
    }
    
    @objc func tapped(_ sender: UITapGestureRecognizer) {
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
    
    open func sizeFont() {
        self.text = text
        
        guard let font = targetFont else {
            return
        }
        var fontSize = font.pointSize * 1.5
        self.font = font.withSize(fontSize)
        if sizeFontToFitText {
            while sizeThatFits(CGSize(width: frame.size.width, height: .greatestFiniteMagnitude)).height >= frame.size.height {
                fontSize -= 0.5
                if fontSize < minimumFontSize {
                    break
                }
                self.font = font.withSize(fontSize)
            }
        }
    }
    
    override open func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if isChecked, let image = image {
            let y = (Swift.max(font?.ascender ?? 0, image.size.height) - image.size.height) / 2.0
            image.draw(at: CGPoint(x: 0, y: y))
        }
    }

}

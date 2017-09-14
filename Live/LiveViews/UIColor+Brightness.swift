//
//  UIColor+Brightness.swift
//  Live
//
//  Created by Denis Bohm on 8/28/17.
//  Copyright © 2017 Firefly Design LLC. All rights reserved.
//

import Foundation

extension UIColor {
    
    public func withBrightness(b: CGFloat, saturation s: CGFloat = 1.0, hue h: CGFloat = 1.0) -> UIColor {
        var hue : CGFloat = 0.0
        var saturation : CGFloat = 0.0
        var brightness : CGFloat = 0.0
        var alpha : CGFloat = 0.0
        
        if self.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
            brightness *= b
            brightness = max(min(brightness, 1.0), 0.0)
            saturation *= s
            saturation = max(min(saturation, 1.0), 0.0)
            hue *= h
            hue = max(min(hue, 1.0), 0.0)
            
            return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
        }
        
        var white: CGFloat = 0.0
        if self.getWhite(&white, alpha: &alpha) {
            white += (b - 1.0)
            white = max(min(b, 1.0), 0.0)
            
            return UIColor(white: white, alpha: alpha)
        }
        
        return self
    }
    
}

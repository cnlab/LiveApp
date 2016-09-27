//
//  StepsView.swift
//  Live
//
//  Created by Denis Bohm on 9/26/16.
//  Copyright © 2016 Firefly Design LLC. All rights reserved.
//

import UIKit

@IBDesignable class StepsView: UIView {

    var startDate = Date()
    var stepCounts: [Int?] = [134, 872, 5201, 2000, 12007, nil, 875]

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func update(startDate: Date, stepCounts: [Int?]) {
        self.startDate = startDate
        self.stepCounts = stepCounts
        setNeedsDisplay()
    }

    func nextDate(date: Date, days: Int) -> Date {
        return NSCalendar.current.date(byAdding: DateComponents(day: days), to: date)!
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        let font = UIFont.systemFont(ofSize: 10.0)
        let style = NSMutableParagraphStyle()
        style.setParagraphStyle(NSParagraphStyle.default)
        style.alignment = NSTextAlignment.center
        let attributes = [NSFontAttributeName: font, NSForegroundColorAttributeName: UIColor.gray, NSParagraphStyleAttributeName: style]

        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        let startDateFormatter = DateFormatter()
        startDateFormatter.dateFormat = "MMM d"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d"

        UIColor.white.setFill()
        let background = UIBezierPath(rect: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        background.fill()

        let fontHeight = font.ascender - font.descender
        let barY = fontHeight
        let barHeight = frame.size.height - fontHeight - fontHeight
        let margin: CGFloat = 8
        var x: CGFloat = 0
        let textY: CGFloat = frame.size.height - fontHeight
        let maxStepCount = stepCounts.reduce(0) { max($0, $1 ?? 0) }
        let width = (frame.size.width - margin * (7 - 1)) / 7
        var lastMonth = -1
        for day in 0 ..< 7 {
            if let stepCount = stepCounts[day] {
                let height = barHeight * CGFloat(stepCount) / CGFloat(maxStepCount)
                let bar = UIBezierPath(rect: CGRect(x: x, y: barY + barHeight - height, width: width, height: height))
                UIColor.blue.setFill()
                bar.fill()

                if stepCount == maxStepCount {
                    let text = numberFormatter.string(for: stepCount)! as NSString
                    let rect = CGRect(x: x, y: 0, width: width, height: fontHeight)
                    text.draw(in: rect, withAttributes: attributes)
                }
            } else {
                let text = "?" as NSString
                let rect = CGRect(x: x, y: barY + barHeight - fontHeight, width: width, height: fontHeight)
                text.draw(in: rect, withAttributes: attributes)
            }

            let date = nextDate(date: startDate, days: day)
            let month = Calendar.current.component(Calendar.Component.month, from: date)
            let formatter = lastMonth != month ? startDateFormatter : dateFormatter
            lastMonth = month
            let text = formatter.string(from: date) as NSString
            text.draw(in: CGRect(x: x, y: textY, width: width, height: fontHeight), withAttributes: attributes)
            x += margin + width
        }
    }

}

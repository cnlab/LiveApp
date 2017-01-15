//
//  StepsView.swift
//  Live
//
//  Created by Denis Bohm on 9/26/16.
//  Copyright © 2016 Firefly Design LLC. All rights reserved.
//

import UIKit

@IBDesignable open class StepsView: UIView {

    @IBInspectable open var enabledStepsColor: UIColor? = UIColor.gray
    @IBInspectable open var enabledBarColor: UIColor? = UIColor.gray
    @IBInspectable open var enabledDateColor: UIColor? = UIColor.gray
    @IBInspectable open var enabledTodayStepsColor: UIColor? = UIColor.darkGray
    @IBInspectable open var enabledTodayBarColor: UIColor? = UIColor.orange
    @IBInspectable open var enabledTodayDateColor: UIColor? = UIColor.darkGray

    @IBInspectable open var disabledStepsColor: UIColor? = UIColor.lightGray
    @IBInspectable open var disabledBarColor: UIColor? = UIColor.lightGray
    @IBInspectable open var disabledDateColor: UIColor? = UIColor.lightGray
    @IBInspectable open var disabledTodayStepsColor: UIColor? = UIColor.gray
    @IBInspectable open var disabledTodayBarColor: UIColor? = UIColor.gray
    @IBInspectable open var disabledTodayDateColor: UIColor? = UIColor.gray

    @IBInspectable open var isEnabled: Bool = false {
        didSet {
            if isEnabled != oldValue {
                isEnabledChanged()
            }
        }
    }

    @IBInspectable open var minimumBarHeight: CGFloat = 1.0
    @IBInspectable open var margin: CGFloat = 8.0
    @IBInspectable open var fontSize: CGFloat = 9.0
    @IBInspectable open var missingSteps: String = "?"
    @IBInspectable open var todayFormat: String? = "'Today'"

    @IBInspectable open var topInset: CGFloat = 4.0
    @IBInspectable open var leftInset: CGFloat = 8.0
    @IBInspectable open var bottomInset: CGFloat = 4.0
    @IBInspectable open var rightInset: CGFloat = 8.0
    open var insets: UIEdgeInsets {
        get {
            return UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        }
    }

    @IBInspectable open var defaultStepCounts: String = "1003, 2872, 3701, 4600, 2332, 740, 4900"
    open var defaultStepCountsArray: [Int?] {
        get {
            var stepCounts: [Int?] = []
            let components = defaultStepCounts.components(separatedBy: ", ")
            for component in components {
                stepCounts.append(Int(component))
            }
            while stepCounts.count > 7 {
                stepCounts.removeLast()
            }
            while stepCounts.count < 7 {
                stepCounts.append(nil)
            }
            return stepCounts
        }
    }

    open var stepsColor: UIColor? { get { return isEnabled ? enabledStepsColor : disabledStepsColor } }
    open var barColor: UIColor? { get { return isEnabled ? enabledBarColor : disabledBarColor } }
    open var dateColor: UIColor? { get { return isEnabled ? enabledDateColor : disabledDateColor } }

    open var todayStepsColor: UIColor? { get { return isEnabled ? enabledTodayStepsColor : disabledTodayStepsColor } }
    open var todayBarColor: UIColor? { get { return isEnabled ? enabledTodayBarColor : disabledTodayBarColor } }
    open var todayDateColor: UIColor? { get { return isEnabled ? enabledTodayDateColor : disabledTodayDateColor } }

    open var startDate = Date()
    open var stepCounts: [Int?] = [nil, nil, nil, nil, nil, nil, nil]

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setDefaults()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setDefaults()
    }

    open func setDefaults() {
        let calendar = Calendar.current
        let startOfToday = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: Date())!
        let endDate = calendar.date(byAdding: .day, value: 1, to: startOfToday)!
        startDate = calendar.date(byAdding: .day, value: -7, to: endDate)!
        stepCounts = defaultStepCountsArray
    }

    open func isEnabledChanged() {
        if !isEnabled {
            setDefaults()
        }
        setNeedsDisplay()
    }

    open func update(startDate: Date, stepCounts: [Int?]) {
        self.startDate = startDate
        self.stepCounts = stepCounts
        setNeedsDisplay()
    }

    open func nextDate(date: Date, days: Int) -> Date {
        return NSCalendar.current.date(byAdding: DateComponents(day: days), to: date)!
    }

    override open func draw(_ rect: CGRect) {
        super.draw(rect)

        let font = UIFont.systemFont(ofSize: fontSize)
        let style = NSMutableParagraphStyle()
        style.setParagraphStyle(NSParagraphStyle.default)
        style.alignment = NSTextAlignment.center

        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        let startDateFormatter = DateFormatter()
        startDateFormatter.dateFormat = "MMM d"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d"

        if let backgroundColor = backgroundColor {
            backgroundColor.setFill()
            let background = UIBezierPath(rect: CGRect(x: 0.0, y: 0.0, width: frame.size.width, height: frame.size.height))
            background.fill()
        }

        let content = CGRect(x: insets.left, y: insets.top, width: frame.size.width - insets.left - insets.right, height: frame.size.height - insets.top - insets.bottom)
        let fontHeight = font.ascender - font.descender
        let barTopY = content.origin.y + fontHeight
        let barHeight = content.size.height - fontHeight - fontHeight
        var x: CGFloat = content.origin.x
        let dateY: CGFloat = content.maxY - fontHeight
        let maxStepCount = stepCounts.reduce(0) { max($0, $1 ?? 0) }
        let days = 7
        let width = (content.size.width - margin * (CGFloat(days) - 1.0)) / CGFloat(days)
        var lastMonth = -1
        for day in 0 ..< days {
            let isToday = day == days - 1
            let stepCount = stepCounts[day] ?? 0
            let height = max(minimumBarHeight, barHeight * CGFloat(stepCount) / CGFloat(maxStepCount))
            let barY = barTopY + barHeight - height

            if let color = isToday ? todayBarColor : barColor {
                color.setFill()
                let bar = UIBezierPath(rect: CGRect(x: x, y: barY, width: width, height: height))
                bar.fill()
            }

            if let color = isToday ? todayStepsColor : stepsColor {
                let text = (stepCounts[day] != nil ? numberFormatter.string(for: stepCount)! : missingSteps) as NSString
                let rect = CGRect(x: x, y: barY - fontHeight, width: width, height: fontHeight)
                let attributes: [String : Any] = [NSFontAttributeName: font, NSParagraphStyleAttributeName: style, NSForegroundColorAttributeName: color]
                text.draw(in: rect, withAttributes: attributes)
            }

            let date = nextDate(date: startDate, days: day)
            let month = Calendar.current.component(Calendar.Component.month, from: date)
            var formatter = lastMonth != month ? startDateFormatter : dateFormatter
            if isToday {
                if let todayFormat = todayFormat {
                    formatter = DateFormatter()
                    formatter.dateFormat = todayFormat
                }
            }
            lastMonth = month

            if let color = isToday ? todayDateColor : dateColor {
                let text = formatter.string(from: date) as NSString
                let rect = CGRect(x: x, y: dateY, width: width, height: fontHeight)
                let attributes: [String : Any] = [NSFontAttributeName: font, NSParagraphStyleAttributeName: style, NSForegroundColorAttributeName: color]
                text.draw(in: rect, withAttributes: attributes)
            }

            x += margin + width
        }
    }

}

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
    @IBInspectable open var enabledBarColor: UIColor? = UIColor(red:0.59, green:0.83, blue:0.81, alpha:1.0) // 150, 212, 206 #96d4ce
    @IBInspectable open var enabledDateColor: UIColor? = UIColor.gray
    @IBInspectable open var enabledTodayStepsColor: UIColor? = UIColor.darkGray
    @IBInspectable open var enabledTodayBarColor: UIColor? = UIColor(red:0.42, green:0.76, blue:0.73, alpha:1.0) // 106, 193, 185 #6ac1b9
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

    @IBInspectable open var dateMargin: CGFloat = 8.0
    @IBInspectable open var todayImageMargin: CGFloat = 8.0
    @IBInspectable open var stepCountMargin: CGFloat = 8.0
    @IBInspectable open var margin: CGFloat = 8.0
    @IBInspectable open var fontSize: CGFloat = 14.0
    @IBInspectable open var missingSteps: String = "?"

    @IBInspectable open var topInset: CGFloat = 4.0
    @IBInspectable open var leftInset: CGFloat = 8.0
    @IBInspectable open var bottomInset: CGFloat = 4.0
    @IBInspectable open var rightInset: CGFloat = 8.0
    open var insets: UIEdgeInsets {
        get {
            return UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        }
    }

    @IBInspectable open var defaultStepCounts: String = "1003, 2872, 3701, 4600, 2332, 74, 4900"
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
    open var todayImage: UIImage? = nil

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

    open func update(startDate: Date, stepCounts: [Int?], todayImage: UIImage?) {
//        self.startDate = startDate
//        self.stepCounts = stepCounts
        self.todayImage = todayImage
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
        style.alignment = NSTextAlignment.left

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
        let days = 7

        let todayImageWidth: CGFloat = todayImage?.size.width ?? 0
        var maxDateWidth: CGFloat = 0
        var maxStepCountWidth: CGFloat = 0
        for day in 0 ..< days {
            let isToday = day == days - 1
            let stepCount = stepCounts[day] ?? 0

            var width: CGFloat = stepCountMargin
            if isToday && (todayImage != nil) {
                width += todayImageWidth
                width += todayImageMargin
            }

            let text = (stepCounts[day] != nil ? numberFormatter.string(for: stepCount)! : missingSteps) as NSString
            let attributes: [String : Any] = [NSFontAttributeName: font, NSParagraphStyleAttributeName: style]
            width += text.size(attributes: attributes).width

            if width > maxStepCountWidth {
                maxStepCountWidth = width
            }

            let date = nextDate(date: startDate, days: day)
            let dateText = dateFormatter.string(from: date)
            let dateWidth = dateText.size(attributes: attributes).width + dateMargin
            if dateWidth > maxDateWidth {
                maxDateWidth = dateWidth
            }
        }

        let barWidth = content.size.width - maxDateWidth - maxStepCountWidth
        let maxStepCount = stepCounts.reduce(0) { max($0, $1 ?? 0) }
        let height = (content.size.height - margin * (CGFloat(days) - 1.0)) / CGFloat(days)
        let cornerRadius = height / 2.0 - 2.0
        let minimumBarWidth = cornerRadius * 2.0
        var y: CGFloat = 0
        for day in 0 ..< days {
            let isToday = day == days - 1
            let stepCount = stepCounts[day] ?? 0
            let width = max(minimumBarWidth, barWidth * CGFloat(stepCount) / CGFloat(maxStepCount))

            var x = content.origin.x
            if let color = isToday ? todayDateColor : dateColor {
                let date = nextDate(date: startDate, days: day)
                let dateText = dateFormatter.string(from: date)
                let attributes: [String : Any] = [NSFontAttributeName: font, NSParagraphStyleAttributeName: style, NSForegroundColorAttributeName: color]
                let dateSize = dateText.size(attributes: attributes)
                let datePoint = CGPoint(x: x + maxDateWidth - dateMargin - dateSize.width, y: y + (height - dateSize.height) / 2.0)
                dateText.draw(at: datePoint, withAttributes: attributes)
            }
            x += maxDateWidth

            if let color = isToday ? todayBarColor : barColor {
                color.setFill()
                let bar = UIBezierPath(roundedRect: CGRect(x: x, y: y, width: width, height: height), cornerRadius: cornerRadius)
                bar.fill()
                x += width
            }

            if isToday, let todayImage = todayImage {
                x += todayImageMargin
                let point = CGPoint(x: x, y: y + (height - todayImage.size.height) / 2.0)
                todayImage.draw(at: point)
                x += todayImage.size.width
            }

            if let color = isToday ? todayStepsColor : stepsColor {
                x += stepCountMargin
                let text = (stepCounts[day] != nil ? numberFormatter.string(for: stepCount)! : missingSteps) as NSString
                let attributes: [String : Any] = [NSFontAttributeName: font, NSParagraphStyleAttributeName: style, NSForegroundColorAttributeName: color]
                let size = text.size(attributes: attributes)
                let point = CGPoint(x: x, y: y + (height - size.height) / 2.0)
                text.draw(at: point, withAttributes: attributes)
            }

            y += margin + height
        }
    }

}

//
//  ValuesViewController.swift
//  Live
//
//  Created by Denis Bohm on 9/9/16.
//  Copyright © 2016 Firefly Design LLC. All rights reserved.
//

import UIKit
import LiveViews

class ValuesViewController: TrackerViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    var letsGoCallback: (() -> Void)? = nil

    let reuseIdentifier = "ValueCell"
    
    @IBOutlet var collectionView: UICollectionView? = nil
    @IBOutlet var mostImportantLabel: VerticalLabelView? = nil
    @IBOutlet var leastImportantLabel: VerticalLabelView? = nil
    @IBOutlet var letsGoButton: UIButton? = nil

    var values = [String]()
    var valueImages: [String: UIImage] = [:]
    var valueImageSize = CGSize()

    var gestureBeganLocation = CGPoint()

    override func viewDidLoad() {
        super.viewDidLoad()

        valueImages[ValueMessageManager.independence] = UIImage(named: "ic_independence")
        valueImages[ValueMessageManager.politics] = UIImage(named: "ic_politics")
        valueImages[ValueMessageManager.spirituality] = UIImage(named: "ic_spirituality")
        valueImages[ValueMessageManager.humor] = UIImage(named: "ic_humor")
        valueImages[ValueMessageManager.fame] = UIImage(named: "ic_fame")
        valueImages[ValueMessageManager.powerAndStatus] = UIImage(named: "ic_power")
        valueImages[ValueMessageManager.familyAndFriends] = UIImage(named: "ic_familyAndFriends")
        valueImages[ValueMessageManager.compassionAndKindness] = UIImage(named: "ic_compassion")
        var imageSize = CGSize()
        for image in valueImages.values {
            imageSize.width = max(imageSize.width, image.size.width)
            imageSize.height = max(imageSize.height, image.size.height)
        }
        valueImageSize = imageSize

        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(ValuesViewController.handleLongGesture(gesture:)))
        longPressGesture.minimumPressDuration = 0.1
        self.collectionView?.addGestureRecognizer(longPressGesture)

        let liveManager = LiveManager.shared
        values = liveManager.orderedValues.value
        liveManager.orderedValues.subscribe(owner: self, observer: orderedValuesChanged)
        
        AncestorUtility.notifyAncestorDidLoad(parent: parent, viewController: self)
    }

    // !!! workaround cell content having wrong size on initial load -denis
    open override func viewDidAppear(_ animated: Bool) {
        collectionView?.reloadData()
        collectionView?.setNeedsLayout()
        collectionView?.layoutIfNeeded()
        collectionView?.reloadData()
    }

    open override func viewDidLayoutSubviews() {
        guard
            let collectionView = self.collectionView,
            let letsGoButton = self.letsGoButton,
            let mostImportantLabel = self.mostImportantLabel,
            let leastImportantLabel = self.leastImportantLabel
        else {
            return
        }

        let basicInsets = UIEdgeInsets(top: mostImportantLabel.frame.origin.y, left: 16.0, bottom: 20.0, right: 16.0)
        var insets = basicInsets
//        insets.top += topLayoutGuide.length
        insets.bottom += bottomLayoutGuide.length
        let spacing: CGFloat = 16.0
        let margin: CGFloat = 12.0
        let x: CGFloat = insets.left + mostImportantLabel.frame.size.width + margin
        let y: CGFloat = insets.top
        let width = view.bounds.width - insets.right - margin - insets.left - 2.0 * mostImportantLabel.frame.size.width
        let contentHeight = view.bounds.height - insets.top - insets.bottom - spacing
        let flexibleHeight = contentHeight - Layout.totalHeight(subviews: [collectionView, letsGoButton], excluding: [collectionView], spacing: spacing)

        if let layout = collectionView.collectionViewLayout as? CollectionViewListLayout {
            let count = CGFloat(values.count)
            layout.itemHeight = (flexibleHeight - layout.minimumLineSpacing * (count - 1)) / count
        }

        var cy = y
        for subview in [collectionView, letsGoButton] {
            Layout.place(subview: subview, x: x, y: &cy, width: width, height: subview == collectionView ? flexibleHeight : nil)
            cy += spacing
        }
        let lx = mostImportantLabel.frame.origin.x
        let lw = mostImportantLabel.frame.size.width
        let lh = collectionView.frame.size.height / 2.0
        cy = mostImportantLabel.frame.origin.y
        Layout.place(subview: mostImportantLabel, x: lx, y: &cy, width: lw, height: lh)
        Layout.place(subview: leastImportantLabel, x: lx, y: &cy, width: lw, height: lh)
    }

    @objc func handleLongGesture(gesture: UILongPressGestureRecognizer) {
        switch(gesture.state) {
        case UIGestureRecognizerState.began:
            let location = gesture.location(in: gesture.view!)
            guard let selectedIndexPath = self.collectionView?.indexPathForItem(at: location) else {
                break
            }
            gestureBeganLocation = location
            collectionView?.beginInteractiveMovementForItem(at: selectedIndexPath)
        case UIGestureRecognizerState.changed:
            var location = gesture.location(in: gesture.view!)
            if let collectionView = self.collectionView {
                location.x = collectionView.frame.size.width / 2.0
            }
            collectionView?.updateInteractiveMovementTargetPosition(location)
        case UIGestureRecognizerState.ended:
            collectionView?.endInteractiveMovement()
        default:
            collectionView?.cancelInteractiveMovement()
        }
    }

    func orderedValuesChanged() {
        let liveManager = LiveManager.shared
        if values != liveManager.orderedValues.value {
            collectionView?.setNeedsDisplay()
        }
    }
    
    @IBAction func letsGo() {
        if let letsGoCallback = letsGoCallback {
            letsGoCallback()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return values.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)

        // Configure the cell
        if let view = cell.subviews.first {
            if let label = view.subviews.first as? ImageLabelView {
                if let index = indexPath.last {
                    let value = values[index]
                    if let icon = valueImages[value] {
                        label.image = icon
                    }
                    label.text = value
                    label.textColor = UIColor.white
                    label.highlightColor = self.view.tintColor
                    label.margin = CGFloat(indexPath.row) * 4.0
                    label.imageWidth = valueImageSize.width
                    label.setNeedsDisplay()
                }
            }
        }
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        cell.setNeedsDisplay()

        return cell
    }

    // MARK: UICollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let sourceIndex = sourceIndexPath.last!
        let value = values.remove(at: sourceIndex)
        let destinationIndex = destinationIndexPath.last!
        values.insert(value, at: destinationIndex)
        
        Tracker.sharedInstance().event(category: "Values", name: "order", value: values.joined(separator: ","))
        
        let liveManager = LiveManager.shared
        liveManager.orderedValues.value = values

        var indexPaths: [IndexPath] = []
        for i in 0 ..< values.count {
            indexPaths.append(IndexPath(row: i, section: 0))
        }
        collectionView.reloadItems(at: indexPaths)
    }

    /*
     // Uncomment this method to specify if the specified item should be highlighted during tracking
     override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */

    /*
     // Uncomment this method to specify if the specified item should be selected
     override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */

    /*
     // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
     override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
     return false
     }

     override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
     return false
     }

     override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
     
     }
     */

}


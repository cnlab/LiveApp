//
//  CollectionViewListLayout.swift
//  Live
//
//  Created by Denis Bohm on 9/22/16.
//  Copyright © 2016 Firefly Design LLC. All rights reserved.
//

import UIKit

class CollectionViewListLayout: UICollectionViewFlowLayout {

    let itemHeight: CGFloat = 30

    override init() {
        super.init()
        setupLayout()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLayout()
    }

    func setupLayout() {
        minimumInteritemSpacing = 0
        minimumLineSpacing = 0
        scrollDirection = .vertical
    }

    func itemWidth() -> CGFloat {
        return collectionView!.frame.width
    }

    override var itemSize: CGSize {
        set {
            self.itemSize = CGSize(width: itemWidth(), height: itemHeight)
        }
        get {
            return CGSize(width: itemWidth(), height: itemHeight)
        }
    }

    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        return collectionView!.contentOffset
    }

}

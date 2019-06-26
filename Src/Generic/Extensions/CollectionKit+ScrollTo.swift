//
//  CollectionKit+ScrollTo.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-29.
//  Copyright © 2018 Hedvig AB. All rights reserved.
//

import Form
import Foundation
import UICollectionView_AnimatedScroll
import UIKit

enum ScrollTo {
    case next, previous, first
}

extension CollectionKit {
    func currentIndex() -> Int {
        return Int(view.contentOffset.x / view.frame.size.width)
    }

    func scrollToFirstItem() {
        view.setContentOffset(
            offset: CGPoint(x: 0, y: 0),
            timingFunction: CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut),
            duration: 0.8
        )
    }

    func hasScrolledToEnd() -> Bool {
        return view.contentOffset.x == view.frame.size.width
    }

    func scrollToNextItem() {
        let currentIndex = self.currentIndex()
        let newIndexPath = IndexPath(row: currentIndex + 1, section: 0)
        let numberOfItems = dataSource.collectionView(
            view,
            numberOfItemsInSection: 0
        )

        if numberOfItems > newIndexPath.row {
            let newPoint = CGPoint(x: view.frame.size.width * CGFloat(newIndexPath.row), y: 0)
            view.setContentOffset(
                offset: newPoint,
                timingFunction: CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut),
                duration: 0.3
            )
        }
    }

    func scrollToPreviousItem() {
        let currentIndex = self.currentIndex()
        let newIndexPath = IndexPath(row: currentIndex - 1, section: 0)

        if newIndexPath.row >= 0 {
            let newPoint = CGPoint(x: view.frame.size.width * CGFloat(newIndexPath.row), y: 0)
            view.setContentOffset(
                offset: newPoint,
                timingFunction: CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut),
                duration: 0.3
            )
        }
    }
}

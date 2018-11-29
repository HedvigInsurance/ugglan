//
//  CollectionKit+ScrollTo.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-29.
//  Copyright © 2018 Hedvig AB. All rights reserved.
//

import Form
import Foundation

extension CollectionKit {
    private func currentIndex() -> Int {
        return Int(view.contentOffset.x / view.frame.size.width)
    }

    func scrollToNextItem() {
        let currentIndex = self.currentIndex()
        let newIndexPath = IndexPath(row: currentIndex + 1, section: 0)
        let numberOfItems = dataSource.collectionView(
            view,
            numberOfItemsInSection: 0
        )

        if numberOfItems > newIndexPath.row {
            view.scrollToItem(at: newIndexPath, at: .centeredHorizontally, animated: true)
        }
    }

    func scrollToPreviousItem() {
        let currentIndex = self.currentIndex()
        let newIndexPath = IndexPath(row: currentIndex - 1, section: 0)

        if newIndexPath.row >= 0 {
            view.scrollToItem(at: newIndexPath, at: .centeredHorizontally, animated: true)
        }
    }
}

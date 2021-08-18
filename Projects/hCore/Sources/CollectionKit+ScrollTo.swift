import Form
import Foundation
import UIKit

enum ScrollTo { case next, previous, first }

extension CollectionKit {
    public var currentIndex: Int {
        let double = view.contentOffset.x / view.frame.size.width

        if double.isNaN { return 0 }

        return Int(double)
    }

    public func scrollToNextItem() {
        let currentIndex = self.currentIndex
        let newIndexPath = IndexPath(row: currentIndex + 1, section: 0)
        let numberOfItems = dataSource.collectionView(view, numberOfItemsInSection: 0)

        if numberOfItems > newIndexPath.row {
            let newPoint = CGPoint(x: view.frame.size.width * CGFloat(newIndexPath.row), y: 0)
            view.setContentOffset(
                offset: newPoint,
                timingFunction: CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut),
                duration: 0.3
            )
        }
    }

    public func scrollToPreviousItem() {
        let currentIndex = self.currentIndex
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

//
//  CollectionKit+ScrollTo.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-29.
//  Copyright © 2018 Hedvig AB. All rights reserved.
//

import Form
import Foundation

class AnimationDriver {
    let collectionView: UICollectionView

    private var currentScrollDisplayLink: CADisplayLink?
    private var currentScrollStartTime = Date()
    private var currentScrollDuration: TimeInterval = 0
    private var currentScrollStartContentOffset: CGFloat = 0.0
    private var currentScrollEndContentOffset: CGFloat = 0.0

    init(collectionView: UICollectionView) {
        self.collectionView = collectionView
    }

    // The curve is hardcoded to linear for simplicity
    func beginAnimatedScroll(toContentOffset contentOffset: CGPoint, animationDuration: TimeInterval) {
        // Cancel previous scroll if needed
        resetCurrentAnimatedScroll()

        // Prevent non-animated scroll
        guard animationDuration != 0 else {
            collectionView.setContentOffset(contentOffset, animated: false)
            return
        }

        // Setup new scroll properties
        currentScrollStartTime = Date()
        currentScrollDuration = animationDuration
        currentScrollStartContentOffset = collectionView.contentOffset.x
        currentScrollEndContentOffset = contentOffset.x

        // Start new scroll
        currentScrollDisplayLink = CADisplayLink(target: self, selector: #selector(handleScrollDisplayLinkTick))
        currentScrollDisplayLink?.add(to: RunLoop.current, forMode: RunLoop.Mode.common)
    }

    @objc private func handleScrollDisplayLinkTick() {
        let animationRatio = CGFloat(abs(currentScrollStartTime.timeIntervalSinceNow) / currentScrollDuration)

        // Animation is finished
        guard animationRatio < 1 else {
            endAnimatedScroll()
            return
        }

        // Animation running, update with incremental content offset
        let deltaContentOffset = animationRatio * (currentScrollEndContentOffset - currentScrollStartContentOffset)

        let newContentOffset = CGPoint(x: currentScrollStartContentOffset + deltaContentOffset, y: 0.0)
        collectionView.setContentOffset(newContentOffset, animated: false)
    }

    private func endAnimatedScroll() {
        let newContentOffset = CGPoint(x: currentScrollEndContentOffset, y: 0)
        collectionView.setContentOffset(newContentOffset, animated: false)

        resetCurrentAnimatedScroll()
    }

    private func resetCurrentAnimatedScroll() {
        currentScrollDisplayLink?.invalidate()
        currentScrollDisplayLink = nil
    }
}

enum ScrollTo {
    case next, previous
}

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
            let animationDriver = AnimationDriver(collectionView: view)
            animationDriver.beginAnimatedScroll(
                toContentOffset: CGPoint(
                    x: CGFloat(newIndexPath.row) * view.frame.size.width,
                    y: 0
                ),
                animationDuration: 0.5
            )
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

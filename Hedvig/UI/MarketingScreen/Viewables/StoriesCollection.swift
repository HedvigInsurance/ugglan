//
//  Collection.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-12-02.
//  Copyright © 2018 Hedvig AB. All rights reserved.
//

import Flow
import Form
import Foundation
import SnapKit
import UIKit

struct StoriesCollection {
    let scrollToSignal: Signal<ScrollTo>
    let marketingStories: ReadSignal<[MarketingStory]>
}

extension StoriesCollection: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()

        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 0
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

        let collectionKit = CollectionKit<EmptySection, MarketingStory>(
            table: Table(),
            layout: flowLayout,
            bag: bag
        )

        collectionKit.view.backgroundColor = HedvigColors.white
        collectionKit.view.isPagingEnabled = true
        collectionKit.view.bounces = false
        collectionKit.view.showsHorizontalScrollIndicator = false
        collectionKit.view.layer.cornerRadius = 10

        if #available(iOS 10.0, *) {
            collectionKit.view.isPrefetchingEnabled = true
        }

        if #available(iOS 11.0, *) {
            collectionKit.view.contentInsetAdjustmentBehavior = .never
        }

        collectionKit.view.alpha = 0
        collectionKit.view.transform = CGAffineTransform(translationX: 0, y: 150)

        bag += collectionKit.delegate.sizeForItemAt.set({ (_) -> CGSize in
            collectionKit.view.frame.size
        })

        bag += scrollToSignal.onValue { direction in
            switch direction {
            case .previous:
                if collectionKit.hasPreviousRow() {
                    collectionKit.updateRowBeforeCurrent()
                    collectionKit.scrollToPreviousItem()
                } else {
                    collectionKit.updateCurrentRow()
                }
            case .next:
                if collectionKit.hasNextRow() {
                    collectionKit.updateRowAfterCurrent()
                    collectionKit.scrollToNextItem()
                } else {
                    collectionKit.updateCurrentRow()
                }
            }
        }

        bag += marketingStories.atOnce().onValue { rows in
            collectionKit.set(Table(rows: rows))
        }

        bag += events.wasAdded.delay(by: 0.5).animatedOnValue(
            style: AnimationStyle.easeOut(duration: 0.25)
        ) {
            collectionKit.view.transform = CGAffineTransform.identity
            collectionKit.view.alpha = 1
        }

        bag += events.wasAdded.onValue {
            collectionKit.view.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.width.equalToSuperview()
                make.height.equalToSuperview()
            }
        }

        return (collectionKit.view, bag)
    }
}

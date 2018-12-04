//
//  Collection.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-12-02.
//  Copyright © 2018 Hedvig AB. All rights reserved.
//

import Apollo
import Flow
import Form
import Foundation
import SnapKit
import UIKit

struct StoriesCollection {
    let client: ApolloClient
    let scrollToSignal: Signal<ScrollTo>
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
        collectionKit.view.isPrefetchingEnabled = true
        collectionKit.view.alpha = 0
        collectionKit.view.transform = CGAffineTransform(translationX: 0, y: 150)
        collectionKit.view.contentInsetAdjustmentBehavior = .never

        bag += collectionKit.delegate.sizeForItemAt.set({ (_) -> CGSize in
            collectionKit.view.frame.size
        })

        bag += scrollToSignal.onValue { direction in
            switch direction {
            case .previous:
                let currentIndex = collectionKit.currentIndex()
                let newItem = collectionKit.table.enumerated().first(where: { (offset, _) -> Bool in
                    offset == currentIndex - 1
                })?.element

                if let newItem = newItem {
                    let changeStep = ChangeStep<MarketingStory, TableIndex>.update(
                        item: newItem,
                        at: TableIndex(section: 0, row: currentIndex - 1)
                    )
                    let tableChange = TableChange<EmptySection, MarketingStory>.row(changeStep)
                    collectionKit.apply(changes: [tableChange])
                }

                collectionKit.scrollToPreviousItem()
            case .next:
                let currentIndex = collectionKit.currentIndex()
                let newItem = collectionKit.table.enumerated().first(where: { (offset, _) -> Bool in
                    offset == currentIndex + 1
                })?.element

                if let newItem = newItem {
                    let changeStep = ChangeStep<MarketingStory, TableIndex>.update(
                        item: newItem,
                        at: TableIndex(section: 0, row: currentIndex + 1)
                    )
                    let tableChange = TableChange<EmptySection, MarketingStory>.row(changeStep)

                    collectionKit.apply(changes: [tableChange])
                }

                collectionKit.scrollToNextItem()
            }
        }

        bag += client.fetch(query: MarketingStoriesQuery()).onValue { result in
            guard let data = result.data else { return }
            let rows = data.marketingStories.map({ (marketingStoryData) -> MarketingStory in
                MarketingStory(apollo: marketingStoryData!)
            })

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

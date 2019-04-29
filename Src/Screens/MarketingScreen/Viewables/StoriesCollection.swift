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
    let pausedCallbacker: Callbacker<Bool>
    let storyDidLoadCallbacker: Callbacker<TableIndex>
}

extension StoriesCollection: CellForRow {
    func registerCells(collectionView: UICollectionView) {
        collectionView.registerCell(cellClass: MarketingStoryVideoCell.self)
        collectionView.registerCell(cellClass: MarketingStoryImageCell.self)
    }

    func cellForRow(
        collectionView: UICollectionView,
        row: MarketingStory,
        index: TableIndex
    ) -> UICollectionViewCell {
        if row.assetType() == .video {
            let cell = collectionView.dequeueCell(cellType: MarketingStoryVideoCell.self, index: index)

            cell.cellDidLoad = {
                self.storyDidLoadCallbacker.callAll(with: index)
            }

            cell.play(marketingStory: row)

            return cell
        }

        let cell = collectionView.dequeueCell(cellType: MarketingStoryImageCell.self, index: index)

        cell.cellDidLoad = {
            self.storyDidLoadCallbacker.callAll(with: index)
        }

        cell.show(marketingStory: row)

        return cell
    }
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
            bag: bag,
            cellForRow: self
        )

        collectionKit.view.backgroundColor = UIColor.darkGray
        collectionKit.view.isPagingEnabled = true
        collectionKit.view.bounces = false
        collectionKit.view.showsHorizontalScrollIndicator = false
        collectionKit.view.isPrefetchingEnabled = true

        if #available(iOS 11.0, *) {
            collectionKit.view.contentInsetAdjustmentBehavior = .never
        }

        bag += pausedCallbacker.signal().onValue({ paused in
            let cell = collectionKit.view.cellForItem(
                at: IndexPath(row: collectionKit.currentIndex(), section: 0)
            )

            if let cell = cell as? MarketingStoryVideoCell {
                if paused {
                    cell.pause()
                } else {
                    cell.resume()
                }
            }
        })

        bag += collectionKit.delegate.sizeForItemAt.set({ (_) -> CGSize in
            collectionKit.view.frame.size
        })

        bag += collectionKit.delegate.willDisplayCell.onValue({ cell, index in
            if let cell = cell as? MarketingStoryVideoCell {
                cell.restart()
            }

            if let nextRow = collectionKit.table.enumerated().first(where: { (offset, _) -> Bool in
                offset == index.row + 1
            }) {
                bag += nextRow.element.cacheData()
            }
        })

        bag += scrollToSignal.onValue { direction in
            switch direction {
            case .previous:
                if collectionKit.hasPreviousRow() {
                    collectionKit.scrollToPreviousItem()
                } else {
                    let cell = collectionKit.view.cellForItem(
                        at: IndexPath(row: 0, section: 0)
                    ) as? MarketingStoryVideoCell
                    cell?.restart()
                }
            case .next:
                if collectionKit.hasNextRow() {
                    collectionKit.scrollToNextItem()
                } else {
                    let currentIndex = collectionKit.currentIndex()
                    let cell = collectionKit.view.cellForItem(
                        at: IndexPath(row: currentIndex, section: 0)
                    ) as? MarketingStoryVideoCell
                    cell?.end()
                }

            case .first:
                collectionKit.scrollToFirstItem()
            }
        }

        bag += marketingStories.atOnce().onValue { rows in
            collectionKit.set(Table(rows: rows))
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

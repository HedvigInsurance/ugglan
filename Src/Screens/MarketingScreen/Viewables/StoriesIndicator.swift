//
//  Indicator.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-12-03.
//  Copyright © 2018 Hedvig AB. All rights reserved.
//

import DeviceKit
import Flow
import Form
import Foundation
import SnapKit
import UIKit

struct StoriesIndicator {
    let scrollToSignal: Signal<ScrollTo>
    let marketingStories: ReadSignal<[MarketingStory]>
    let endScreenCallbacker: Callbacker<Void>
    let pausedCallbacker: Callbacker<Bool>
    let storyDidLoadSignal: Signal<TableIndex>
    let scrollTo: (_ direction: ScrollTo) -> Void
}

extension StoriesIndicator: CellForRow {
    func registerCells(collectionView: UICollectionView) {
        collectionView.registerCell(cellClass: MarketingStoryIndicatorCell.self)
    }

    func cellForRow(
        collectionView: UICollectionView,
        row: MarketingStoryIndicator,
        index: TableIndex
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueCell(cellType: MarketingStoryIndicatorCell.self, index: index)

        cell.prepare(marketingStoryIndicator: row)

        if row.contentHasLoaded {
            cell.start {
                self.scrollTo(.next)
            }
        }

        return cell
    }
}

extension StoriesIndicator: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()

        let minimumLineSpacing: CGFloat = 5

        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = minimumLineSpacing
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)

        let collectionKit = CollectionKit<EmptySection, MarketingStoryIndicator>(
            table: Table(),
            layout: flowLayout,
            bag: bag,
            cellForRow: self
        )
        collectionKit.view.backgroundColor = UIColor.clear
        
        bag += collectionKit.delegate.sizeForItemAt.set { _ -> CGSize in
            let numberOfItems = CGFloat(collectionKit.dataSource.collectionView(
                collectionKit.view,
                numberOfItemsInSection: 0
            ))
            let sectionInset = (flowLayout.sectionInset.left + flowLayout.sectionInset.right) / numberOfItems

            return CGSize(
                width: collectionKit.view.frame.width / numberOfItems - minimumLineSpacing - sectionInset,
                height: 2.5
            )
        }

        bag += pausedCallbacker.signal().onValue { paused in
            guard let storiesIndicator = collectionKit.table.enumerated().filter({ (_, indicator) -> Bool in
                indicator.focused
            }).first else { return }
            guard let index = collectionKit.table.lastIndex(of: storiesIndicator.element) else { return }

            let cell = collectionKit.view.cellForItem(
                at: IndexPath(row: index.row, section: index.section)
            )

            if let cell = cell as? MarketingStoryIndicatorCell {
                if paused {
                    cell.pause()
                } else {
                    cell.resume()
                }
            }
        }

        bag += pausedCallbacker.signal().onValue { paused in
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                collectionKit.view.alpha = paused ? 0 : 1
            }, completion: nil)
        }

        let marketingStoryIndicatorsCallbacker = Callbacker<[MarketingStoryIndicator]>()
        let marketingStoryIndicatorsSignal = marketingStoryIndicatorsCallbacker.signal()

        let currentFocusedStorySignal = marketingStoryIndicatorsSignal.map {
            marketingStoryIndicators -> MarketingStoryIndicator? in
            marketingStoryIndicators.filter { marketingStoryIndicator -> Bool in
                marketingStoryIndicator.focused
            }.first
        }

        bag += marketingStoryIndicatorsSignal
            .onValue { marketingStoryIndicators in
                collectionKit.set(Table(rows: marketingStoryIndicators), animation: .none)
            }

        bag += storyDidLoadSignal.onValue { index in
            let newRows = collectionKit.table.enumerated().map {
                (offset, marketingStoryIndicator) -> MarketingStoryIndicator in
                MarketingStoryIndicator(
                    duration: marketingStoryIndicator.duration,
                    focused: marketingStoryIndicator.focused,
                    id: marketingStoryIndicator.id,
                    shown: marketingStoryIndicator.shown,
                    contentHasLoaded: offset == index.row || marketingStoryIndicator.contentHasLoaded
                )
            }

            marketingStoryIndicatorsCallbacker.callAll(with: newRows)
        }

        bag += scrollToSignal
            .withLatestFrom(
                combineLatest(marketingStoryIndicatorsSignal, currentFocusedStorySignal)
            )
            .filter(predicate: { (_, latestFrom) -> Bool in
                latestFrom.1 != nil
            }).onValue { direction, latestFrom in
                let (marketingStoryIndicators, currentFocusedStory) = latestFrom

                if direction == .first {
                    let newRows = marketingStoryIndicators.enumerated().map {
                        (offset, marketingStoryIndicator) -> MarketingStoryIndicator in
                        MarketingStoryIndicator(
                            duration: marketingStoryIndicator.duration,
                            focused: offset == 0,
                            id: marketingStoryIndicator.id,
                            shown: offset == 0,
                            contentHasLoaded: marketingStoryIndicator.contentHasLoaded
                        )
                    }

                    marketingStoryIndicatorsCallbacker.callAll(with: newRows)

                    return
                }

                let index = marketingStoryIndicators.firstIndex(of: currentFocusedStory!)!
                let newIndex = direction == .next ? index + 1 : index - 1

                if newIndex > marketingStoryIndicators.count - 1 {
                    self.endScreenCallbacker.callAll()
                    return
                } else if newIndex < 0 {
                    collectionKit.updateCurrentRow()
                    return
                }

                let newRows = marketingStoryIndicators.enumerated().map {
                    (offset, marketingStoryIndicator) -> MarketingStoryIndicator in
                    MarketingStoryIndicator(
                        duration: marketingStoryIndicator.duration,
                        focused: newIndex == offset,
                        id: marketingStoryIndicator.id,
                        shown: offset < newIndex,
                        contentHasLoaded: marketingStoryIndicator.contentHasLoaded
                    )
                }

                marketingStoryIndicatorsCallbacker.callAll(with: newRows)
            }

        bag += marketingStories.atOnce().map {
            (marketingStories: [MarketingStory]) -> [MarketingStoryIndicator] in
            marketingStories.enumerated().map {
                (offset, marketingStory) -> MarketingStoryIndicator in
                MarketingStoryIndicator(
                    duration: marketingStory.duration,
                    focused: offset == 0,
                    id: marketingStory.id,
                    shown: offset == 0,
                    contentHasLoaded: false
                )
            }
        }.onValue { marketingStoryIndicators in
            marketingStoryIndicatorsCallbacker.callAll(with: marketingStoryIndicators)
        }

        bag += collectionKit.view.makeConstraints(wasAdded: events.wasAdded).onValue { make, safeArea in
            if Device.hasRoundedCorners {
                make.top.equalTo(safeArea.layoutGuide)
            } else {
                make.top.equalTo(20)
            }

            make.width.equalToSuperview()
            make.height.equalTo(2.5)
            make.centerX.equalToSuperview().inset(2.5)
        }

        return (collectionKit.view, bag)
    }
}

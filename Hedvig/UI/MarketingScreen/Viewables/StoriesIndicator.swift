//
//  Indicator.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-12-03.
//  Copyright © 2018 Hedvig AB. All rights reserved.
//

import Apollo
import Flow
import Form
import Foundation
import SnapKit
import UIKit

struct StoriesIndicator {
    let client: ApolloClient
    let scrollToSignal: Signal<ScrollTo>
    let scrollTo: (_ direction: ScrollTo) -> Void
}

struct MarketingStoryIndicator: Decodable, Hashable {
    let duration: TimeInterval
    let id: String
    var focused: Bool
    var shown: Bool

    init(duration: TimeInterval, focused: Bool, id: String, shown: Bool) {
        self.duration = duration
        self.focused = focused
        self.id = id
        self.shown = shown
    }

    init(apollo marketingStoryData: MarketingStoriesQuery.Data.MarketingStory, focused: Bool) {
        duration = marketingStoryData.duration ?? 0
        id = String(marketingStoryData.id)
        shown = false
        self.focused = focused
    }
}

extension MarketingStoryIndicator: Reusable {
    static func makeAndReconfigure() -> (
        make: UIView,
        reconfigure: (MarketingStoryIndicator?, MarketingStoryIndicator) -> Disposable
    ) {
        let view = UIView()
        view.layer.cornerRadius = 1.25
        view.clipsToBounds = true
        view.backgroundColor = HedvigColors.white.withAlphaComponent(0.5)

        let progressView = UIView()
        view.addSubview(progressView)

        progressView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalToSuperview()
            make.center.equalToSuperview()
        }

        return (view, { _, current in
            let bag = DisposeBag()

            if current.focused {
                progressView.backgroundColor = HedvigColors.white
                progressView.transform = CGAffineTransform(translationX: -progressView.frame.width, y: 0)
                progressView.alpha = 1

                var progress: Double = 0.0
                let progressChunk: Double = current.duration / 1000

                bag += Signal(every: progressChunk).onValue {
                    progress +=
                        progressChunk
                        / current.duration

                    progressView.transform = CGAffineTransform(
                        translationX: -(progressView.frame.width - (progressView.frame.width * CGFloat(progress))),
                        y: 0
                    )

                    if progress > 1 {
                        bag.dispose()
                    }
                }
            } else if current.shown {
                progressView.backgroundColor = UIColor.white
                progressView.transform = CGAffineTransform.identity
            } else {
                progressView.backgroundColor = UIColor.clear
            }

            return bag
        })
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
            bag: bag
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

        var rows: [MarketingStoryIndicator] = []
        let timerBag = DisposeBag()

        bag += scrollToSignal.onValue({ direction in
            let currentFocusedRow = rows.filter({ marketingStoryIndicator -> Bool in
                marketingStoryIndicator.focused
            }).first

            let index = rows.firstIndex(of: currentFocusedRow!)!
            let newIndex = direction == .next ? index + 1 : index - 1

            timerBag.dispose()

            if newIndex > rows.count - 1 || newIndex < 0 {
                collectionKit.updateCurrentRow()

                timerBag += Signal(after: currentFocusedRow!.duration).onValue {
                    if newIndex < rows.count - 1 {
                        self.scrollTo(.next)
                    }
                }

                return
            }

            let newRows = rows.enumerated().map({ (offset, marketingStoryIndicator) -> MarketingStoryIndicator in
                MarketingStoryIndicator(
                    duration: marketingStoryIndicator.duration,
                    focused: newIndex == offset,
                    id: marketingStoryIndicator.id,
                    shown: offset < newIndex
                )
            })

            timerBag += Signal(after: newRows[newIndex].duration).onValue {
                if newIndex + 1 <= rows.count - 1 {
                    self.scrollTo(.next)
                }
            }

            rows = newRows

            collectionKit.set(Table(rows: newRows))
        })

        bag += client.fetch(query: MarketingStoriesQuery()).onValue { result in
            guard let data = result.data else { return }
            let newRows = data.marketingStories.enumerated().map({
                (offset, marketingStoryData) -> MarketingStoryIndicator in
                MarketingStoryIndicator(apollo: marketingStoryData!, focused: offset == 0)
            })

            timerBag += Signal(after: newRows[0].duration).onValue {
                self.scrollTo(.next)
            }

            rows = newRows

            collectionKit.set(Table(rows: rows), animation: .none)
        }

        bag += events.wasAdded.onValue {
            collectionKit.view.snp.makeConstraints({ make in
                guard let superview = collectionKit.view.superview else { return }
                let safeAreaLayoutGuide = superview.safeAreaLayoutGuide

                make.width.equalToSuperview()
                make.height.equalTo(2.5)
                make.top.equalTo(safeAreaLayoutGuide.snp.top)
                make.centerX.equalToSuperview().inset(2.5)
            })
        }

        return (collectionKit.view, bag)
    }
}

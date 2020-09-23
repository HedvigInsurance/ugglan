//
//  PagerCollection.swift
//  project
//
//  Created by Gustaf Gunér on 2019-06-12.
//

import Flow
import Form
import Foundation
import hCore
import Presentation
import UIKit

public struct PagerItem {
    let id: UUID
    let content: AnyPresentable<UIViewController, Disposable>

    public init(id: UUID, content: AnyPresentable<UIViewController, Disposable>) {
        self.id = id
        self.content = content
    }
}

extension PagerItem: Reusable {
    public static func makeAndConfigure() -> (make: UIView, configure: (PagerItem) -> Disposable) {
        let sliderPageView = UIView()

        return (sliderPageView, { sliderPage in
            sliderPageView.subviews.forEach { view in
                view.removeFromSuperview()
            }

            let (contentScreen, contentDisposable) = sliderPage.content.materialize()

            sliderPageView.addSubview(contentScreen.view)

            contentScreen.view.snp.makeConstraints { make in
                make.width.height.equalToSuperview()
            }

            return contentDisposable
        })
    }
}

struct PagerCollection {
    @ReadWriteState var pages: [PagerItem]
    let scrollToNextSignal: Signal<Void>
    let scrolledToPageIndexCallbacker: Callbacker<Int>
}

extension PagerCollection: Viewable {
    func materialize(events _: ViewableEvents) -> (UICollectionView, Disposable) {
        let bag = DisposeBag()

        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 0
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

        let collectionKit = CollectionKit<EmptySection, PagerItem>(
            table: Table(),
            layout: flowLayout,
            holdIn: bag
        )

        collectionKit.view.backgroundColor = .clear
        collectionKit.view.isPagingEnabled = true
        collectionKit.view.bounces = true
        collectionKit.view.showsHorizontalScrollIndicator = false
        collectionKit.view.isPrefetchingEnabled = true
        collectionKit.view.contentInsetAdjustmentBehavior = .never

        bag += collectionKit.delegate.sizeForItemAt.set { (_) -> CGSize in
            collectionKit.view.frame.size
        }

        bag += $pages.atOnce().onValue { pages in
            collectionKit.set(Table(rows: pages), animation: .none, rowIdentifier: { $0.id })
        }

        bag += scrollToNextSignal.onValue {
            collectionKit.scrollToNextItem()
        }

        bag += collectionKit.view
            .signal(for: \.contentOffset)
            .compactMap { _ in collectionKit.currentIndex }
            .distinct()
            .onValue { pageIndex in
                self.scrolledToPageIndexCallbacker.callAll(with: pageIndex)
            }

        return (collectionKit.view, bag)
    }
}

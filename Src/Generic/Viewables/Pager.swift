//
//  Pager.swift
//  project
//
//  Created by Gustaf Gunér on 2019-06-12.
//

import Flow
import Form
import Foundation
import Presentation
import UIKit

struct PagerScreen {
    let id: UUID
    let content: AnyPresentable<UIViewController, Disposable>

    init(id: UUID, content: AnyPresentable<UIViewController, Disposable>) {
        self.id = id
        self.content = content
    }
}

extension PagerScreen: Reusable {
    static func makeAndConfigure() -> (make: UIView, configure: (PagerScreen) -> Disposable) {
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

struct Pager {
    let dataSignal = ReadWriteSignal<[PagerScreen]>([])
    let scrollToNextSignal: Signal<Void>
    let scrolledToPageIndexCallbacker: Callbacker<Int>
}

extension Pager: Viewable {
    func materialize(events _: ViewableEvents) -> (UICollectionView, Disposable) {
        let bag = DisposeBag()

        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 0
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

        let collectionKit = CollectionKit<EmptySection, PagerScreen>(
            table: Table(),
            layout: flowLayout,
            bag: bag
        )

        collectionKit.view.backgroundColor = .transparent
        collectionKit.view.isPagingEnabled = true
        collectionKit.view.bounces = true
        collectionKit.view.showsHorizontalScrollIndicator = false
        collectionKit.view.isPrefetchingEnabled = true

        if #available(iOS 11.0, *) {
            collectionKit.view.contentInsetAdjustmentBehavior = .never
        }

        bag += collectionKit.delegate.sizeForItemAt.set({ (_) -> CGSize in
            collectionKit.view.frame.size
        })

        bag += dataSignal.atOnce().onValue { sliderPageArray in
            collectionKit.set(Table(rows: sliderPageArray), animation: .none, rowIdentifier: { $0.id })
        }

        bag += scrollToNextSignal.onValue {
            collectionKit.scrollToNextItem()
        }

        bag += collectionKit.view
            .contentOffsetSignal.compactMap { _ in collectionKit.currentIndex() }
            .distinct()
            .onValue { pageIndex in
                self.scrolledToPageIndexCallbacker.callAll(with: pageIndex)
            }

        return (collectionKit.view, bag)
    }
}

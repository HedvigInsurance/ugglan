//
//  Slider.swift
//  project
//
//  Created by Gustaf Gunér on 2019-06-12.
//

import Foundation
import Form
import Presentation
import Flow
import UIKit

struct Slider {
    let dataSignal = ReadWriteSignal<[SliderPage]>([])
    let scrollToNextSignal: Signal<Void>
    let scrolledToPageIndexCallbacker: Callbacker<Int>
    let scrolledToEndCallbacker: Callbacker<Void>
}

struct DummySlide {}
extension DummySlide: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let viewController = UIViewController()
        let bag = DisposeBag()
        
        return (viewController, bag)
    }
}

extension Slider: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 0
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        let collectionKit = CollectionKit<EmptySection, SliderPage>(
            table: Table(),
            layout: flowLayout,
            bag: bag
        )
        
        collectionKit.view.backgroundColor = .transparent
        collectionKit.view.isPagingEnabled = true
        collectionKit.view.bounces = true
        collectionKit.view.showsHorizontalScrollIndicator = false
        collectionKit.view.isPrefetchingEnabled = false
        
        if #available(iOS 11.0, *) {
            collectionKit.view.contentInsetAdjustmentBehavior = .never
        }
        
        bag += collectionKit.delegate.sizeForItemAt.set({ (_) -> CGSize in
            collectionKit.view.frame.size
        })
        
        bag += dataSignal.atOnce().onValue { sliderPageArray in
            var extendedSliderPageArray = sliderPageArray
            let dummySlide = DummySlide()
            extendedSliderPageArray.append(SliderPage(id: "0", content: AnyPresentable(dummySlide)))
            
            collectionKit.set(Table(rows: extendedSliderPageArray), animation: .none, rowIdentifier: { $0.id })
        }
        
        bag += scrollToNextSignal.onValue {
            collectionKit.scrollToNextItem()
        }
        
        bag += collectionKit.view
            .contentOffsetSignal.compactMap { _ in collectionKit.currentIndex() }
            .distinct()
            .onValue { pageIndex in
                self.scrolledToPageIndexCallbacker.callAll(with: pageIndex)
                if (collectionKit.hasScrolledToEnd()) {
                    self.scrolledToEndCallbacker.callAll()
                }
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

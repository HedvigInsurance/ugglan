//
//  KeyGearImageCarousel.swift
//  test
//
//  Created by Sam Pettersson on 2020-01-27.
//

import Foundation
import Form
import UIKit
import Flow

struct KeyGearImageCarousel {}

extension KeyGearImageCarousel: Viewable {
    func materialize(events: ViewableEvents) -> (UICollectionView, Disposable) {
        let table = Table(rows: [
            KeyGearImageCarouselItem(imageUrl: URL(string: "https://images.unsplash.com/photo-1571863033270-be3332c7f524?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=2100&q=80")!),
            KeyGearImageCarouselItem(imageUrl: URL(string: "https://images.unsplash.com/photo-1571863033270-be3332c7f524?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=2100&q=80")!)
        ])
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionKit = CollectionKit<EmptySection, KeyGearImageCarouselItem>(table: table, layout: layout)
        collectionKit.view.isPagingEnabled = true
        let bag = DisposeBag()
        
        bag += collectionKit.delegate.sizeForItemAt.set({ _ -> CGSize in
            return CGSize(width: collectionKit.view.frame.width, height: 400)
        })
        
        collectionKit.view.snp.makeConstraints { make in
            make.height.equalTo(400)
        }
        
        let pagerDots = PagerDots()
        
        
        
        bag += collectionKit.view.add(pagerDots) { pagerDotsView in
            pagerDotsView.snp.makeConstraints { make in
                make.bottom.equalToSuperview().inset(20)
            }
        }
        
        return (collectionKit.view, bag)
    }
}

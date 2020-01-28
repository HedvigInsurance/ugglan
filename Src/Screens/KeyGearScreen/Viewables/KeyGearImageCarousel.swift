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
        let collectionKit = CollectionKit<EmptySection, KeyGearImageCarouselItem>(table: table, layout: layout)
        let bag = DisposeBag()
        
        
        
        return (collectionKit.view, bag)
    }
}

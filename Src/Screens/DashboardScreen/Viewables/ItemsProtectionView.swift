//
//  ItemsProtectionView.swift
//  ugglan
//
//  Created by Axel Backlund on 2019-04-03.
//

import Flow
import Form
import Foundation

struct ItemsProtectionView {}

extension ItemsProtectionView: Viewable {
    func materialize(events _: ViewableEvents) -> (ProtectionView, Disposable) {
        let bag = DisposeBag()
        
        let itemsProtectionView = ProtectionView(
            title: "Mina prylar",
            icon: Asset.itemsPlain,
            color: .purple
        )
        
        return (itemsProtectionView, bag)
    }
}

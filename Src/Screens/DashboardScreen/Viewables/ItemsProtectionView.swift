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
    func materialize(events _: ViewableEvents) -> (ExpandableProtectionRow<LargeIconTitleSubtitle, LargeIconTitleSubtitle>, Disposable) {
        let bag = DisposeBag()
        
        let itemsIconTitleSubtitle = LargeIconTitleSubtitle(
            title: "Mina prylar",
            icon: Asset.itemsPlain
        )
        
        let expandableRow = ExpandableProtectionRow(content: itemsIconTitleSubtitle, expandableContent: itemsIconTitleSubtitle)
        
        return (expandableRow, bag)
    }
}

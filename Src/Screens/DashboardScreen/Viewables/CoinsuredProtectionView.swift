//
//  CoinsuredRow.swift
//  ugglan
//
//  Created by Axel Backlund on 2019-04-03.
//

import Flow
import Form
import Foundation

struct CoinsuredProtectionView {}

extension CoinsuredProtectionView: Viewable {
    func materialize(events _: ViewableEvents) -> (ExpandableRow<LargeIconTitleSubtitle, PerilCollection>, Disposable) {
        let bag = DisposeBag()
        
        let coinsuredIconTitleSubtitle = LargeIconTitleSubtitle(
            title: String(.PROFILE_MY_COINSURED_ROW_SUBTITLE(amountCoinsured: "min sambo")),
            icon: Asset.coinsuredPlain
        )
        
        let coinsuredPerilCollection = PerilCollection(perils: ["one", "two"])
        
        let expandableView = ExpandableRow(content: coinsuredIconTitleSubtitle, expandedContent: coinsuredPerilCollection)
        
        return (expandableView, bag)
    }
}

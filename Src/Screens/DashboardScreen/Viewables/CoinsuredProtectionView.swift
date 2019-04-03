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
    func materialize(events _: ViewableEvents) -> (ProtectionView, Disposable) {
        let bag = DisposeBag()
        
        let coinsuredProtectionView = ProtectionView(
            title: String(.PROFILE_MY_COINSURED_ROW_SUBTITLE(amountCoinsured: "min sambo")),
            icon: Asset.coinsuredPlain,
            color: .darkPurple
        )
        
        return (coinsuredProtectionView, bag)
    }
}

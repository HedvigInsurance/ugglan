//
//  CoinsuredRow.swift
//  ugglan
//
//  Created by Axel Backlund on 2019-04-03.
//

import Flow
import Form
import Foundation

struct CoinsuredRow {}

extension CoinsuredRow: Viewable {
    func materialize(events _: ViewableEvents) -> (MyProtectionView, Disposable) {
        let bag = DisposeBag()
        
        let coinsuredRow = MyProtectionView(mode: .coinsured)
        
        return (coinsuredRow, bag)
    }
}

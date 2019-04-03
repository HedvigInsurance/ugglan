//
//  HomeProtectionView.swift
//  ugglan
//
//  Created by Axel Backlund on 2019-04-03.
//

import Flow
import Form
import Foundation

struct HomeProtectionView {}

extension HomeProtectionView: Viewable {
    func materialize(events _: ViewableEvents) -> (ProtectionView, Disposable) {
        let bag = DisposeBag()
        
        let homeProtectionView = ProtectionView(
            title: "Islandsvägen 13",
            icon: Asset.homePlain,
            color: .pink
        )
        
        return (homeProtectionView, bag)
    }
}

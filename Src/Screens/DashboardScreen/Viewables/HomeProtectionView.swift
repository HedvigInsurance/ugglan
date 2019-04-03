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
    func materialize(events _: ViewableEvents) -> (ExpandableProtectionRow<LargeIconTitleSubtitle, LargeIconTitleSubtitle>, Disposable) {
        let bag = DisposeBag()
        
        let homeIconTitleSubtitle = LargeIconTitleSubtitle(
            title: "Islandsvägen 13",
            icon: Asset.homePlain
        )
        
        let expandableRow = ExpandableProtectionRow(content: homeIconTitleSubtitle, expandableContent: homeIconTitleSubtitle)
        
        return (expandableRow, bag)
    }
}

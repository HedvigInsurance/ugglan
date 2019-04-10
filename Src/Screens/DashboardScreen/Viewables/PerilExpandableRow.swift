//
//  PerilLargeIconSubtitle.swift
//  ugglan
//
//  Created by Axel Backlund on 2019-04-08.
//

import Flow
import Form
import Foundation

struct PerilExpandableRow {
    let perilsDataSignal: ReadWriteSignal<DashboardQuery.Data.Insurance.PerilCategory?> = ReadWriteSignal(nil)
    let index: Int
    
    init(index: Int) {
        self.index = index
    }
}

enum PerilCategoryIcon: Int {
    case coinsured = 0
    case home = 1
    case items = 2
}

extension PerilCategoryIcon {
    var image: ImageAsset {
        switch self {
        case .coinsured: return Asset.coinsuredPlain
        case .home: return Asset.homePlain
        case .items: return Asset.itemsPlain
        }
    }
}

extension PerilExpandableRow: Viewable {
    func materialize(events _: ViewableEvents) -> (ExpandableRow<LargeIconTitleSubtitle, PerilCollection>, Disposable) {
        let bag = DisposeBag()
        
        let perilCollectionTitleSubtitle = LargeIconTitleSubtitle()
        
        bag += perilsDataSignal.atOnce()
            .filter { $0?.title != nil }
            .map { $0!.title! }
            .bindTo(perilCollectionTitleSubtitle.titleSignal)
        
        bag += perilsDataSignal.atOnce()
            .filter { $0?.description != nil }
            .map { $0!.description! }
            .bindTo(perilCollectionTitleSubtitle.subtitleSignal)
        
        perilCollectionTitleSubtitle.imageSignal.value = PerilCategoryIcon(rawValue: index)?.image
        
        let coinsuredPerilCollection = PerilCollection()
        bag += perilsDataSignal.atOnce()
            .bindTo(coinsuredPerilCollection.perilsDataSignal)
        
        let expandableView = ExpandableRow(content: perilCollectionTitleSubtitle, expandedContent: coinsuredPerilCollection)
        bag += expandableView.isOpenSignal.bindTo(perilCollectionTitleSubtitle.isOpenSignal)
        
        return (expandableView, bag)
    }
}

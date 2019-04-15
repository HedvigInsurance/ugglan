//
//  MoreInfoExpandableRow.swift
//  ugglan
//
//  Created by Axel Backlund on 2019-04-10.
//

import Flow
import Form
import Foundation

struct MoreInfoExpandableRow {}

extension MoreInfoExpandableRow: Viewable {
    func materialize(events _: ViewableEvents) -> (ExpandableRow<LargeIconTitleSubtitle, MoreInfo>, Disposable) {
        let bag = DisposeBag()
        
        let contentView = LargeIconTitleSubtitle()
        contentView.titleSignal.value = String(key: .DASHBOARD_MORE_INFO_BUTTON_TEXT)
        contentView.subtitleSignal.value = "om din hemförsäkring"
        contentView.imageSignal.value = Asset.moreInfoPlain
        
        let moreInfoView = MoreInfo()
        
        let expandableView = ExpandableRow(content: contentView, expandedContent: moreInfoView)
        bag += expandableView.isOpenSignal.bindTo(contentView.isOpenSignal)
        
        return (expandableView, bag)
    }
}

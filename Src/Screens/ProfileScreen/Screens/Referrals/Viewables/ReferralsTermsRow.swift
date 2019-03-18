//
//  ReferralsTermsRow.swift
//  ugglan
//
//  Created by Sam Pettersson on 2019-03-18.
//

import Flow
import Form
import Foundation
import Presentation

struct ReferralsTermsRow {
    let presentingViewController: UIViewController
}

extension ReferralsTermsRow: Viewable {
    func materialize(events: SelectableViewableEvents) -> (RowView, Disposable) {
        let bag = DisposeBag()
        
        let row = RowView()
        row.append(UILabel(value: String(.REFERRALS_TERMS_ROW_TITLE), style: .rowTitle))
        
        let arrow = Icon(frame: .zero, icon: Asset.chevronRight, iconWidth: 20)
        
        row.append(arrow)
        
        arrow.snp.makeConstraints { make in
            make.width.equalTo(20)
        }
        
        bag += events.onSelect.onValue {
            guard let url = URL(string: String(.REFERRALS_TERMS_WEBSITE_URL)) else { return }
            UIApplication.shared.openURL(url)
        }
        
        return (row, bag)
    }
}

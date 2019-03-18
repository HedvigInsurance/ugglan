//
//  ReferralsTitle.swift
//  ugglan
//
//  Created by Sam Pettersson on 2019-03-18.
//

import Foundation
import Flow
import UIKit
import Form

struct ReferralsTitle {}

extension ReferralsTitle: Viewable {
    func materialize(events: ViewableEvents) -> (UIStackView, Disposable) {
        let bag = DisposeBag()
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .center
        
        let incentive = RemoteConfigContainer().referralsIncentive()
        
        let title = MultilineLabel(
            styledText: StyledText(
                text: String(.REFERRALS_TITLE(incentive: String(incentive))),
                style: .standaloneLargeTitle
            )
        )
        
        bag += view.addArangedSubview(title) { titleView in
            titleView.snp.makeConstraints { make in
                make.width.equalToSuperview().inset(20)
            }
        }
                
        return (view, bag)
    }
}

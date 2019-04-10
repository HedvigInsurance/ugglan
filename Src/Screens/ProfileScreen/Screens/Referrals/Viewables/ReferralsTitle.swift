//
//  ReferralsTitle.swift
//  ugglan
//
//  Created by Sam Pettersson on 2019-03-18.
//

import Flow
import Form
import Foundation
import UIKit

struct ReferralsTitle {}

extension ReferralsTitle: Viewable {
    func materialize(events _: ViewableEvents) -> (UIStackView, Disposable) {
        let bag = DisposeBag()
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .center

        let title = MultilineLabel(
            styledText: StyledText(
                text: String(key: .REFERRALS_TITLE),
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

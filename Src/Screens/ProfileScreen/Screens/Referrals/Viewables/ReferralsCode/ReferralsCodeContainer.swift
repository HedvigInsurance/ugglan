//
//  ReferralsCodeContainer.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-05-31.
//

import Flow
import Form
import Foundation
import UIKit

struct ReferralsCodeContainer {}

extension ReferralsCodeContainer: Viewable {
    func materialize(events _: ViewableEvents) -> (UIStackView, Disposable) {
        let bag = DisposeBag()
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 5

        let titleLabel = MultilineLabel(
            value: String(key: .REFERRAL_PROGRESS_CODE_TITLE),
            style: TextStyle.centeredBodyOffBlack
        )
        bag += stackView.addArranged(titleLabel)

        let referralsCode = ReferralsCode()
        bag += stackView.addArranged(referralsCode)

        return (stackView, bag)
    }
}

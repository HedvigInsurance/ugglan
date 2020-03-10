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
import ComponentKit

struct ReferralsTitle {
    let peopleLeftToInviteSignal: ReadSignal<Int?>
    let incentiveSignal: ReadSignal<Int?>
}

extension ReferralsTitle: Viewable {
    func materialize(events _: ViewableEvents) -> (UIStackView, Disposable) {
        let bag = DisposeBag()
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .center
        view.spacing = 8

        let title = MultilineLabel(
            value: String(key: .REFERRAL_PROGRESS_HEADLINE),
            style: TextStyle.standaloneLargeTitle.centerAligned
        )

        bag += view.addArranged(title) { titleView in
            titleView.snp.makeConstraints { make in
                make.width.equalToSuperview().inset(20)
            }
        }

        let description = MultilineLabel(
            value: "",
            style: TextStyle.bodyOffBlack.centerAligned
        )

        bag += incentiveSignal
            .atOnce()
            .compactMap { $0 }
            .map { String(key: .REFERRAL_PROGRESS_BODY(referralValue: String($0))) }
            .map { StyledText(text: $0, style: TextStyle.bodyOffBlack.centerAligned) }
            .bindTo(description.styledTextSignal)

        bag += view.addArranged(description) { descriptionView in
            descriptionView.snp.makeConstraints { make in
                make.width.equalToSuperview().inset(20)
            }
        }

        return (view, bag)
    }
}

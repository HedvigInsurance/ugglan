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
        view.spacing = 8

        let title = MultilineLabel(
            styledText: StyledText(
                text: String(key: .REFERRALS_TITLE),
                style: TextStyle.standaloneLargeTitle.centerAligned
            )
        )

        bag += view.addArranged(title) { titleView in
            titleView.snp.makeConstraints { make in
                make.width.equalToSuperview().inset(20)
            }
        }
        
        let description = MultilineLabel(
            styledText: StyledText(
                text: "Du ger bort 10 kr rabatt och får 10 kr rabatt för varje vän du bjuder in via din unika länk! Kan du nå gratis försäkring?",
                style: TextStyle.bodyOffBlack.centerAligned
            )
        )
        
        bag += view.addArranged(description) { descriptionView in
            descriptionView.snp.makeConstraints { make in
                make.width.equalToSuperview().inset(20)
            }
        }

        return (view, bag)
    }
}

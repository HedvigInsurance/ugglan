//
//  ReferralsCode.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-05-31.
//

import Apollo
import Flow
import Form
import Foundation
import UIKit

struct ReferralsCode {
    let client: ApolloClient

    init(client: ApolloClient = ApolloContainer.shared.client) {
        self.client = client
    }
}

extension ReferralsCode: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()
        let view = UIView()
        view.backgroundColor = .white
        view.layer.borderColor = UIColor.offLightGray.cgColor
        view.layer.borderWidth = 1

        bag += view.didLayoutSignal.onValue { _ in
            view.layer.cornerRadius = view.frame.height / 2
        }

        let codeSignal = client.fetch(query: ReferralCodeQuery()).valueSignal.compactMap { $0.data?.memberReferralCampaign?.referralInformation.code }

        bag += view.copySignal.withLatestFrom(codeSignal.plain()).atValue { _, code in
            UIPasteboard.general.value = code
        }.feedback(type: .success)

        let codeContainer = UIStackView()
        codeContainer.layoutMargins = UIEdgeInsets(horizontalInset: 10, verticalInset: 5)
        codeContainer.isLayoutMarginsRelativeArrangement = true

        let codeTextStyle = TextStyle(
            font: HedvigFonts.circularStdBold!,
            color: UIColor.purple
        ).centerAligned.lineHeight(2.4).resized(to: 16).restyled { (style: inout TextStyle) in
            style.highlightedColor = .darkPurple
        }

        let codeLabel = MultilineLabel(value: "HDVGET", style: codeTextStyle)
        bag += codeSignal.map { code in
            StyledText(text: code, style: codeTextStyle)
        }.bindTo(codeLabel.styledTextSignal)

        let loadableCodeLabel = LoadableView(view: codeLabel, initialLoadingState: true)

        bag += Signal(every: 2).onValue { _ in
            loadableCodeLabel.isLoadingSignal.value = !loadableCodeLabel.isLoadingSignal.value
        }

        bag += codeContainer.addArranged(loadableCodeLabel)
        view.addSubview(codeContainer)

        codeContainer.snp.makeConstraints { make in
            make.trailing.leading.top.bottom.equalToSuperview()
        }

        return (view, bag)
    }
}

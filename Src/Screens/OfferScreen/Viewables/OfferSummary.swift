//
//  OfferSummary.swift
//  test
//
//  Created by Sam Pettersson on 2019-10-03.
//

import Flow
import Form
import Foundation
import UIKit

struct OfferSummary {}

extension OfferSummary: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()
        let outerView = UIStackView()
        outerView.axis = .vertical
        
        let containerView = UIView()
        containerView.backgroundColor = .primaryBackground
        outerView.addArrangedSubview(containerView)

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.layoutMargins = UIEdgeInsets(top: 40, left: 20, bottom: 40, right: 20)
        stackView.isLayoutMarginsRelativeArrangement = true

        containerView.addSubview(stackView)

        stackView.snp.makeConstraints { make in
            make.trailing.leading.top.bottom.equalToSuperview()
        }

        let titleLabel = ApolloMultilineLabel(query: OfferQuery()) {
            StyledText(text: $0.insurance.address ?? "", style: TextStyle.standaloneLargeTitle.aligned(to: .center))
        }
        bag += stackView.addArranged(titleLabel)

        let descriptionLabel = MultilineLabel(
            value: String(key: .OFFER_HOUSE_SUMMARY_DESC),
            style: TextStyle.body.centerAligned
        )
        bag += stackView.addArranged(descriptionLabel)

        bag += stackView.addArranged(Spacing(height: 10))

        bag += stackView.addArranged(ExpandableContent(content: InsuranceSummarySection(), isExpanded: .static(false)))
        
        return (outerView, bag)
    }
}

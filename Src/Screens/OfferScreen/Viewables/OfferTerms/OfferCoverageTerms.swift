//
//  OfferTerms.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-08-19.
//

import Apollo
import Flow
import Form
import Foundation
import UIKit

struct OfferCoverageTerms {
    let client: ApolloClient
    let insuredAtOtherCompanySignal: ReadSignal<Bool>

    init(
        insuredAtOtherCompanySignal: ReadSignal<Bool>,
        client: ApolloClient = ApolloContainer.shared.client
    ) {
        self.insuredAtOtherCompanySignal = insuredAtOtherCompanySignal
        self.client = client
    }
}

extension OfferCoverageTerms: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let outerView = UIStackView()
        outerView.axis = .vertical

        let containerView = UIView()
        containerView.backgroundColor = .white
        outerView.addArrangedSubview(containerView)

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 20
        stackView.layoutMargins = UIEdgeInsets(top: 40, left: 20, bottom: 40, right: 20)
        stackView.isLayoutMarginsRelativeArrangement = true

        containerView.addSubview(stackView)

        stackView.snp.makeConstraints { make in
            make.trailing.leading.top.bottom.equalToSuperview()
        }

        let bag = DisposeBag()

        let image = UIImageView(image: Asset.offerTerms.image)
        image.contentMode = .scaleAspectFit

        image.snp.makeConstraints { make in
            make.height.equalTo(125)
        }

        stackView.addArrangedSubview(image)

        let titleLabel = MultilineLabel(value: String(key: .OFFER_TERMS_TITLE), style: TextStyle.rowTitleBold.centerAligned)
        bag += stackView.addArranged(titleLabel)

        bag += stackView.addArranged(OfferTermsBulletPoints())
        bag += stackView.addArranged(OfferTermsLinks())

        let notInsuredAtOtherCompanyBlob = WhenEnabled(insuredAtOtherCompanySignal.map { !$0 }, {
            Blob(color: .darkPurple, position: .top)
        }) { view in
            view.backgroundColor = .white
        }

        bag += outerView.addArranged(notInsuredAtOtherCompanyBlob)

        return (outerView, bag)
    }
}

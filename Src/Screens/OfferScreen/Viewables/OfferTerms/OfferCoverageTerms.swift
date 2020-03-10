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
import Common
import ComponentKit

struct OfferCoverageTerms {
    @Inject var client: ApolloClient
    let insuredAtOtherCompanySignal: ReadSignal<Bool>

    init(
        insuredAtOtherCompanySignal: ReadSignal<Bool>
    ) {
        self.insuredAtOtherCompanySignal = insuredAtOtherCompanySignal
    }
}

extension OfferCoverageTerms: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let outerView = UIStackView()
        outerView.axis = .vertical

        let containerView = UIView()
        containerView.backgroundColor = .primaryBackground
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
        image.tintColor = UIColor(dynamic: { trait -> UIColor in
            trait.userInterfaceStyle == .dark ? .white : .black
        })

        image.snp.makeConstraints { make in
            make.height.equalTo(125)
        }

        stackView.addArrangedSubview(image)

        let titleLabel = MultilineLabel(value: String(key: .OFFER_TERMS_TITLE), style: TextStyle.rowTitleBold.centerAligned)
        bag += stackView.addArranged(titleLabel)

        bag += stackView.addArranged(OfferTermsBulletPoints())
        bag += stackView.addArranged(OfferTermsLinks())

        let notInsuredAtOtherCompanyBlob = WhenEnabled(insuredAtOtherCompanySignal.map { !$0 }, {
            Blob(color: Offer.primaryAccentColor, position: .top)
        }) { view in
            view.backgroundColor = .primaryBackground
        }

        bag += outerView.addArranged(notInsuredAtOtherCompanyBlob)

        return (outerView, bag)
    }
}

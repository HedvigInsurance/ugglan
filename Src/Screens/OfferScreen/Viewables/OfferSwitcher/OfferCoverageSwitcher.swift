//
//  OfferCoverageSwitcher.swift
//  project
//
//  Created by Sam Pettersson on 2019-08-20.
//

import Apollo
import Flow
import Form
import Foundation
import UIKit

struct OfferCoverageSwitcher {
    @Inject var client: ApolloClient
}

extension OfferCoverageSwitcher: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()

        let outerView = UIStackView()
        outerView.axis = .vertical

        bag += outerView.addArranged(Blob(color: .secondaryBackground, position: .top)) { blobView in
            blobView.backgroundColor = .primaryBackground
        }

        let containerView = UIView()
        containerView.backgroundColor = .secondaryBackground
        outerView.addArrangedSubview(containerView)

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 15
        stackView.layoutMargins = UIEdgeInsets(top: 40, left: 20, bottom: 40, right: 20)
        stackView.isLayoutMarginsRelativeArrangement = true

        containerView.addSubview(stackView)

        stackView.snp.makeConstraints { make in
            make.trailing.leading.top.bottom.equalToSuperview()
        }

        let image = UIImageView(image: Asset.offerSwitcher.image)
        image.contentMode = .scaleAspectFit

        image.snp.makeConstraints { make in
            make.height.equalTo(125)
        }

        stackView.addArrangedSubview(image)

        let titleLabel = MultilineLabel(value: "", style: TextStyle.rowTitleBold.centerAligned)
        bag += stackView.addArranged(titleLabel) { titleLabel in
            titleLabel.snp.makeConstraints { make in
                make.width.equalToSuperview().multipliedBy(0.6)
            }
        }

        bag += client.fetch(query: OfferQuery())
            .valueSignal
            .compactMap { $0.data?.insurance.previousInsurer }
            .map { previousInsurer in
                if !previousInsurer.switchable {
                    return String(key: .OFFER_SWITCH_TITLE_NON_SWITCHABLE_APP)
                }

                return String(key: .OFFER_SWITCH_TITLE_APP(insurer: previousInsurer.displayName ?? ""))
            }
            .map { StyledText(text: $0, style: TextStyle.rowTitleBold.centerAligned) }
            .bindTo(titleLabel.styledTextSignal)

        bag += stackView.addArranged(OfferSwitcherBulletList())

        bag += outerView.addArranged(Blob(color: Offer.primaryAccentColor, position: .top)) { blobView in
            blobView.backgroundColor = .secondaryBackground
        }

        return (outerView, bag)
    }
}

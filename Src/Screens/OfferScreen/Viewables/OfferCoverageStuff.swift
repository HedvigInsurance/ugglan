//
//  OfferCoverageStuff.swift
//  project
//
//  Created by Sam Pettersson on 2019-08-05.
//

import Apollo
import Flow
import Form
import Foundation
import UIKit

struct OfferCoverageStuff {
    @Inject var client: ApolloClient
    let presentingViewController: UIViewController

    init(
        presentingViewController: UIViewController
    ) {
        self.presentingViewController = presentingViewController
    }
}

extension OfferCoverageStuff: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()

        let outerView = UIStackView()
        outerView.axis = .vertical
        bag += outerView.addArranged(Blob(color: .secondaryBackground, position: .bottom)) { blobView in
            blobView.backgroundColor = .primaryBackground
        }

        let containerView = UIView()
        containerView.backgroundColor = .primaryBackground
        outerView.addArrangedSubview(containerView)

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 10, right: 20)
        stackView.isLayoutMarginsRelativeArrangement = true

        containerView.addSubview(stackView)

        stackView.snp.makeConstraints { make in
            make.trailing.leading.top.bottom.equalToSuperview()
        }

        let image = UIImageView(image: Asset.offerStuff.image)
        image.contentMode = .scaleAspectFit

        image.snp.makeConstraints { make in
            make.height.equalTo(125)
        }

        stackView.addArrangedSubview(image)

        let titleLabel = MultilineLabel(value: String(key: .OFFER_STUFF_PROTECTION_TITLE), style: .rowTitleBold)
        bag += stackView.addArranged(titleLabel)

        let descriptionLabel = MultilineLabel(value: "", style: TextStyle.body.colored(.tertiaryText))

        bag += client
            .fetch(query: OfferQuery())
            .valueSignal
            .compactMap { $0.data?.insurance.type }
            .onValue { insuranceType in
                if insuranceType.isStudent {
                    descriptionLabel.styledTextSignal.value = StyledText(
                        text: String(key: .OFFER_STUFF_PROTECTION_DESCRIPTION(protectionAmount: Localization.Key.STUFF_PROTECTION_AMOUNT_STUDENT)),
                        style: descriptionLabel.styledTextSignal.value.style
                    )
                } else {
                    descriptionLabel.styledTextSignal.value = StyledText(
                        text: String(key: .OFFER_STUFF_PROTECTION_DESCRIPTION(protectionAmount: Localization.Key.STUFF_PROTECTION_AMOUNT)),
                        style: descriptionLabel.styledTextSignal.value.style
                    )
                }
            }

        bag += stackView.addArranged(descriptionLabel)

        let perilCollection = PerilCollection(
            presentingViewController: presentingViewController,
            collectionViewInset: UIEdgeInsets(horizontalInset: 0, verticalInset: 20)
        )

        bag += client.fetch(query: OfferQuery()).valueSignal.compactMap { $0.data?.insurance.arrangedPerilCategories.stuff?.fragments.perilCategoryFragment }.bindTo(perilCollection.perilsDataSignal)
        bag += stackView.addArranged(perilCollection)

        bag += outerView.addArranged(Blob(color: .primaryBackground, position: .bottom)) { blobView in
            blobView.backgroundColor = .secondaryBackground
        }

        return (outerView, bag)
    }
}

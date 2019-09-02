//
//  OfferCoverageHome.swift
//  project
//
//  Created by Sam Pettersson on 2019-08-05.
//

import Apollo
import Flow
import Form
import Foundation
import UIKit

struct OfferCoverageHome {
    let client: ApolloClient
    let presentingViewController: UIViewController

    init(
        presentingViewController: UIViewController,
        client: ApolloClient = ApolloContainer.shared.client
    ) {
        self.presentingViewController = presentingViewController
        self.client = client
    }
}

extension OfferCoverageHome: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let outerView = UIStackView()
        outerView.axis = .vertical

        let containerView = UIView()
        containerView.backgroundColor = .secondaryBackground
        outerView.addArrangedSubview(containerView)

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.layoutMargins = UIEdgeInsets(horizontalInset: 20, verticalInset: 10)
        stackView.isLayoutMarginsRelativeArrangement = true

        containerView.addSubview(stackView)

        stackView.snp.makeConstraints { make in
            make.trailing.leading.top.bottom.equalToSuperview()
        }

        let bag = DisposeBag()

        let image = UIImageView(image: Asset.offerHome.image)
        image.contentMode = .scaleAspectFit

        image.snp.makeConstraints { make in
            make.height.equalTo(125)
        }

        stackView.addArrangedSubview(image)

        let titleLabel = MultilineLabel(value: "", style: .rowTitleBold)
        bag += stackView.addArranged(titleLabel)

        bag += client.fetch(query: OfferQuery())
            .valueSignal
            .compactMap { $0.data?.insurance.address }
            .map { StyledText(text: $0, style: .rowTitleBold) }
            .bindTo(titleLabel, \.styledTextSignal.value)

        let descriptionLabel = MultilineLabel(value: String(key: .OFFER_APARTMENT_PROTECTION_DESCRIPTION), style: TextStyle.body.colored(.darkGray))
        bag += stackView.addArranged(descriptionLabel)

        let perilCollection = PerilCollection(
            presentingViewController: presentingViewController,
            collectionViewInset: UIEdgeInsets(horizontalInset: 0, verticalInset: 20)
        )
        bag += client.fetch(query: OfferQuery()).valueSignal.compactMap { $0.data?.insurance.arrangedPerilCategories.home?.fragments.perilCategoryFragment }.bindTo(perilCollection.perilsDataSignal)
        bag += stackView.addArranged(perilCollection)

        return (outerView, bag)
    }
}

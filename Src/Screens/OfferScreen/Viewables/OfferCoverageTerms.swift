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
    let presentingViewController: UIViewController

    init(
        presentingViewController: UIViewController,
        client: ApolloClient = ApolloContainer.shared.client
    ) {
        self.presentingViewController = presentingViewController
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
        stackView.spacing = 15
        stackView.layoutMargins = UIEdgeInsets(top: 40, left: 20, bottom: 20, right: 20)
        stackView.isLayoutMarginsRelativeArrangement = true

        containerView.addSubview(stackView)

        stackView.snp.makeConstraints { make in
            make.trailing.leading.top.bottom.equalToSuperview()
        }

        let bag = DisposeBag()

        let image = UIImageView(image: Asset.offerMe.image)
        image.contentMode = .scaleAspectFit

        image.snp.makeConstraints { make in
            make.height.equalTo(125)
        }

        stackView.addArrangedSubview(image)

        let titleLabel = MultilineLabel(value: String(key: .OFFER_PERSONAL_PROTECTION_TITLE), style: .rowTitleBold)
        bag += stackView.addArranged(titleLabel)

        let descriptionLabel = MultilineLabel(value: String(key: .OFFER_PERSONAL_PROTECTION_DESCRIPTION), style: TextStyle.body.colored(.darkGray))
        bag += stackView.addArranged(descriptionLabel)

        let perilCollection = PerilCollection(
            presentingViewController: presentingViewController,
            collectionViewInset: UIEdgeInsets(horizontalInset: 0, verticalInset: 20)
        )
        bag += client.fetch(query: OfferQuery()).valueSignal.compactMap { $0.data?.insurance.arrangedPerilCategories.me?.fragments.perilCategoryFragment }.bindTo(perilCollection.perilsDataSignal)
        bag += stackView.addArranged(perilCollection)

        bag += outerView.addArranged(Blob(color: .darkPurple, position: .top)) { blobView in
            blobView.backgroundColor = .offWhite
        }

        return (outerView, bag)
    }
}

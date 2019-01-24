//
//  SelectedCharity.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2019-01-23.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Apollo
import Flow
import Form
import Foundation

struct SelectedCharity {
    let client: ApolloClient
    let animateEntry: Bool

    init(
        client: ApolloClient = HedvigApolloClient.shared.client!,
        animateEntry: Bool
    ) {
        self.client = client
        self.animateEntry = animateEntry
    }
}

extension SelectedCharity: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()

        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true

        let stackView = UIStackView()
        stackView.distribution = .equalSpacing
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.edgeInsets = UIEdgeInsets(
            top: 20,
            left: 20,
            bottom: 20,
            right: 20
        )
        stackView.isLayoutMarginsRelativeArrangement = true

        scrollView.addSubview(stackView)

        bag += client.watch(query: SelectedCharityQuery()).compactMap { $0.data?.cashback }.onValue { cashback in
            for subview in stackView.arrangedSubviews {
                subview.removeFromSuperview()
            }

            let circleIcon = CircleIcon(
                iconAsset: Asset.charityPlain,
                iconWidth: 90,
                spacing: 70,
                backgroundColor: .white
            )
            bag += stackView.addArangedSubview(circleIcon)

            let titleLabel = UILabel(value: cashback.name ?? "", style: .blockRowTitle)
            stackView.addArrangedSubview(titleLabel)

            let descriptionLabel = MultilineLabel(
                styledText: StyledText(text: cashback.description ?? "", style: .blockRowDescription)
            )
            bag += stackView.addArangedSubview(descriptionLabel)
        }

        if animateEntry {
            stackView.alpha = 0
            stackView.transform = CGAffineTransform(translationX: 0, y: 100)

            bag += events.wasAdded.delay(by: 1.2).animated(style: SpringAnimationStyle.lightBounce()) {
                stackView.alpha = 1
                stackView.transform = CGAffineTransform.identity
            }
        }

        stackView.makeConstraints(wasAdded: events.wasAdded).onValue { make, _ in
            make.trailing.equalToSuperview()
            make.leading.equalToSuperview()
            make.width.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        return (scrollView, bag)
    }
}

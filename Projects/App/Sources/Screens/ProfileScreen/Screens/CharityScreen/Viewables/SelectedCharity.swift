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
import hCore
import hCoreUI
import hGraphQL
import UIKit

struct SelectedCharity {
    @Inject var client: ApolloClient
    let animateEntry: Bool
    let presentingViewController: UIViewController

    init(
        animateEntry: Bool,
        presentingViewController: UIViewController
    ) {
        self.animateEntry = animateEntry
        self.presentingViewController = presentingViewController
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
        stackView.spacing = 30
        stackView.edgeInsets = UIEdgeInsets(
            top: 20,
            left: 20,
            bottom: 20,
            right: 20
        )
        stackView.isLayoutMarginsRelativeArrangement = true

        scrollView.addSubview(stackView)

        bag += client.watch(query: GraphQL.SelectedCharityQuery()).compactMap { $0.cashback }.onValue { cashback in
            for subview in stackView.arrangedSubviews {
                subview.removeFromSuperview()
            }

            let charityLogo = CharityLogo(url: URL(string: cashback.imageUrl!)!)
            bag += stackView.addArranged(charityLogo) { view in
                view.snp.makeConstraints { make in
                    make.height.equalTo(190)
                }
            }

            let infoContainer = UIView()
            infoContainer.backgroundColor = .secondaryBackground
            infoContainer.layer.cornerRadius = 8

            let infoContainerStackView = UIStackView()
            infoContainerStackView.axis = .vertical
            infoContainerStackView.spacing = 5
            infoContainerStackView.edgeInsets = UIEdgeInsets(
                top: 24,
                left: 16,
                bottom: 24,
                right: 16
            )
            infoContainerStackView.isLayoutMarginsRelativeArrangement = true

            let titleLabel = UILabel(value: cashback.name ?? "", style: .brand(.headline(color: .primary)))
            infoContainerStackView.addArrangedSubview(titleLabel)

            let descriptionLabel = MultilineLabel(
                styledText: StyledText(text: cashback.description ?? "", style: .brand(.body(color: .secondary)))
            )
            bag += infoContainerStackView.addArranged(descriptionLabel)

            infoContainer.addSubview(infoContainerStackView)
            stackView.addArrangedSubview(infoContainer)

            infoContainerStackView.snp.makeConstraints { make in
                make.width.height.centerX.centerY.equalToSuperview()
            }

            bag += infoContainerStackView.didLayoutSignal.onValue { _ in
                let size = infoContainerStackView.systemLayoutSizeFitting(CGSize.zero)

                infoContainer.snp.remakeConstraints { make in
                    make.height.equalTo(size.height)
                    make.width.equalToSuperview().inset(20)
                }
            }

            let charityInformationButton = CharityInformationButton(presentingViewController: self.presentingViewController)

            bag += stackView.addArranged(charityInformationButton)
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

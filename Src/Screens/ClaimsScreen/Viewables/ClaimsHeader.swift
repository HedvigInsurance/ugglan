//
//  ClaimsHeader.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-04-23.
//

import Apollo
import Flow
import Form
import Foundation
import UIKit

struct ClaimsHeader {
    let presentingViewController: UIViewController
    let client: ApolloClient

    init(
        presentingViewController: UIViewController,
        client: ApolloClient = ApolloContainer.shared.client
    ) {
        self.presentingViewController = presentingViewController
        self.client = client
    }

    struct Title {}
    struct Description {}
    struct InactiveMessage {
        let client: ApolloClient

        init(client: ApolloClient = ApolloContainer.shared.client) {
            self.client = client
        }
    }
}

extension ClaimsHeader.Title: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .center

        let bag = DisposeBag()

        let label = MultilineLabel(
            value: String(key: .CLAIMS_HEADER_TITLE),
            style: TextStyle.standaloneLargeTitle.centered()
        )

        bag += view.addArranged(label) { view in
            view.snp.makeConstraints { make in
                make.top.equalTo(10)
                make.width.equalToSuperview().multipliedBy(0.7)
            }
        }

        return (view, bag)
    }
}

extension ClaimsHeader.Description: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .center

        let bag = DisposeBag()

        let label = MultilineLabel(
            value: String(key: .CLAIMS_HEADER_SUBTITLE),
            style: TextStyle.body.centered()
        )

        bag += view.addArranged(label) { view in
            view.snp.makeConstraints { make in
                make.width.equalToSuperview().multipliedBy(0.8)
            }
        }

        return (view, bag)
    }
}

extension ClaimsHeader.InactiveMessage: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .center
        view.isHidden = true

        let bag = DisposeBag()

        let card = UIView()
        card.backgroundColor = .offLightGray
        card.layer.cornerRadius = 10

        view.addArrangedSubview(card)

        card.snp.makeConstraints { make in
            make.trailing.leading.top.bottom.equalToSuperview()
        }

        let cardContent = UIStackView()
        cardContent.axis = .vertical
        cardContent.isLayoutMarginsRelativeArrangement = true
        cardContent.edgeInsets = UIEdgeInsets(horizontalInset: 24, verticalInset: 24)
        cardContent.alpha = 0
        card.addSubview(cardContent)

        cardContent.snp.makeConstraints { make in
            make.trailing.leading.top.bottom.equalToSuperview()
        }

        let label = MultilineLabel(
            value: String(key: .CLAIMS_INACTIVE_MESSAGE),
            style: TextStyle.bodyOffBlack.centered()
        )

        bag += cardContent.addArranged(label) { view in
            view.snp.makeConstraints { make in
                make.width.equalToSuperview().multipliedBy(0.8)
                make.center.equalToSuperview()
            }
        }

        bag += client.insuranceIsActiveSignal()
            .wait(until: view.hasWindowSignal)
            .filter { !$0 }
            .delay(by: 0.5)
            .animated(style: SpringAnimationStyle.lightBounce()) { _ in
                bag += Signal(after: 0.25).animated(style: AnimationStyle.easeOut(duration: 0.25)) { _ in
                    cardContent.alpha = 1
                }

                view.isHidden = false
            }

        return (view, bag)
    }
}

extension ClaimsHeader: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let view = UIStackView()
        view.layoutMargins = UIEdgeInsets(horizontalInset: 15, verticalInset: 0)
        view.axis = .vertical
        view.isLayoutMarginsRelativeArrangement = true
        view.spacing = 15
        let bag = DisposeBag()

        let inactiveMessage = InactiveMessage()
        bag += view.addArranged(inactiveMessage)

        let imageView = UIImageView()
        imageView.image = Asset.claimsHeader.image
        imageView.contentMode = .scaleAspectFit

        imageView.snp.makeConstraints { make in
            make.height.equalTo(imageView.image?.size.height ?? 0)
            make.width.equalTo(imageView.image?.size.width ?? 0)
        }

        view.addArrangedSubview(imageView)

        let title = Title()
        bag += view.addArranged(title)

        let description = Description()
        bag += view.addArranged(description)

        let button = Button(title: String(key: .CLAIMS_HEADER_ACTION_BUTTON), type: .standard(backgroundColor: .purple, textColor: .white))

        bag += button.onTapSignal.onValue {
            self.presentingViewController.present(
                DraggableOverlay(
                    presentable: HonestyPledge(),
                    presentationOptions: [.defaults, .prefersLargeTitles(false), .largeTitleDisplayMode(.never), .prefersNavigationBarHidden(true)]
                )
            )
        }

        bag += view.addArranged(button.wrappedIn(UIStackView())) { stackView in
            bag += client.insuranceIsActiveSignal().bindTo(stackView, \.isUserInteractionEnabled)
            bag += client.insuranceIsActiveSignal()
                .map { $0 ? 1 : 0.5 }
                .animated(style: AnimationStyle.easeOut(duration: 0.25)) { alpha in
                    stackView.alpha = alpha
                }

            stackView.axis = .vertical
            stackView.alignment = .center
        }

        return (view, bag)
    }
}

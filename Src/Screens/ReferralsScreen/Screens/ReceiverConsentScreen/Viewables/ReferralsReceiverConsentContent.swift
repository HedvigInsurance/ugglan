//
//  ReferralsReceiverConsentContent.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-06-10.
//

import Flow
import Form
import Foundation
import UIKit

struct ReferralsReceiverConsentContent {
    var didTapDecline: Signal<Void> {
        return didTapDeclineCallbacker.providedSignal
    }

    var didTapAccept: Signal<Void> {
        return didTapAcceptCallbacker.providedSignal
    }

    private let didTapDeclineCallbacker = Callbacker<Void>()
    private let didTapAcceptCallbacker = Callbacker<Void>()
}

extension ReferralsReceiverConsentContent: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()

        let scrollView = UIScrollView()

        let containerView = UIStackView()
        containerView.axis = .horizontal
        containerView.alignment = .center
        containerView.layoutMargins = UIEdgeInsets(horizontalInset: 25, verticalInset: 25)
        containerView.isLayoutMarginsRelativeArrangement = true

        scrollView.embedView(containerView, scrollAxis: .vertical)

        let view = UIStackView()
        view.spacing = 28
        view.axis = .vertical
        view.alignment = .center
        
        let logoImageContainer = UIStackView()
        logoImageContainer.axis = .horizontal
        logoImageContainer.alignment = .center
        
        let logoImageView = UIImageView()
        logoImageView.image = Asset.wordmark.image
        logoImageView.contentMode = .scaleAspectFit
        
        logoImageView.snp.makeConstraints { make in
            make.height.equalTo(30)
        }
        
        logoImageContainer.addArrangedSubview(logoImageView)
        view.addArrangedSubview(logoImageContainer)

        let headerImageContainer = UIStackView()
        headerImageContainer.axis = .horizontal
        headerImageContainer.alignment = .center

        let headerImageView = UIImageView()
        headerImageView.image = Asset.inviteSuccess.image
        headerImageView.contentMode = .scaleAspectFit

        headerImageView.snp.makeConstraints { make in
            make.height.equalTo(270)
        }

        headerImageContainer.addArrangedSubview(headerImageView)
        view.addArrangedSubview(headerImageContainer)

        let title = MultilineLabel(
            value: String(key: .REFERRAL_STARTSCREEN_HEADLINE(referralValue: "10")),
            style: TextStyle.standaloneLargeTitle.colored(.black).aligned(to: .center)
        )
        bag += view.addArranged(title)

        let description = MultilineLabel(
            value: String(key: .REFERRAL_STARTSCREEN_BODY(referralValue: "10")),
            style: TextStyle.bodyOffBlack.aligned(to: .center)
        )
        bag += view.addArranged(description)

        let buttonsContainer = UIStackView()
        buttonsContainer.axis = .vertical
        buttonsContainer.spacing = 15
        buttonsContainer.layoutMargins = UIEdgeInsets(horizontalInset: 0, verticalInset: 15)
        buttonsContainer.isLayoutMarginsRelativeArrangement = true

        let shadowView = UIView()

        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor.offWhite.withAlphaComponent(0.2).cgColor,
            UIColor.offWhite.cgColor,
        ]
        gradient.locations = [0, 0.1, 0.9, 1]
        shadowView.layer.addSublayer(gradient)

        bag += shadowView.didLayoutSignal.onValue { _ in
            gradient.frame = shadowView.bounds
        }

        buttonsContainer.addSubview(shadowView)

        shadowView.snp.makeConstraints { make in
            make.width.height.centerY.centerX.equalToSuperview()
        }

        let acceptDiscountButton = Button(
            title: String(key: .REFERRAL_STARTSCREEN_BTN_CTA),
            type: .standard(backgroundColor: .purple, textColor: .white)
        )
        bag += buttonsContainer.addArranged(acceptDiscountButton.wrappedIn(UIStackView())) { stackView in
            stackView.axis = .vertical
            stackView.alignment = .center
        }

        bag += acceptDiscountButton.onTapSignal.onValue { _ in
            self.didTapAcceptCallbacker.callAll()
        }

        let declineButton = Button(
            title: String(key: .REFERRAL_STARTSCREEN_BTN_SKIP),
            type: .pillTransparent(backgroundColor: .lightGray, textColor: .offBlack)
        )
        bag += buttonsContainer.addArranged(declineButton.wrappedIn(UIStackView())) { stackView in
            stackView.axis = .vertical
            stackView.alignment = .center
        }

        bag += declineButton.onTapSignal.onValue { _ in
            self.didTapDeclineCallbacker.callAll()
        }

        bag += scrollView.embedPinned(buttonsContainer, edge: .bottom, minHeight: 70)

        containerView.addArrangedSubview(view)

        return (scrollView, bag)
    }
}

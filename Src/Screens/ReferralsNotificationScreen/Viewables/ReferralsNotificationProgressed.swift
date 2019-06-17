//
//  ReferralsNotificationProgressed.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-06-04.
//

import Flow
import Form
import Foundation
import UIKit

struct ReferralsNotificationProgressed {
    var didTapCancel: Signal<Void> {
        return didTapCancelCallbacker.providedSignal
    }

    var didTapOpenReferrals: Signal<Void> {
        return didTapOpenReferralsCallbacker.providedSignal
    }

    private let didTapCancelCallbacker = Callbacker<Void>()
    private let didTapOpenReferralsCallbacker = Callbacker<Void>()
}

extension ReferralsNotificationProgressed: Viewable {
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
        view.spacing = 15
        view.axis = .vertical
        view.alignment = .center

        let headerImageContainer = UIStackView()
        headerImageContainer.axis = .horizontal
        headerImageContainer.alignment = .center

        let headerImageView = UIImageView()
        headerImageView.image = Asset.inviteSuccessDark.image
        headerImageView.contentMode = .scaleAspectFit

        headerImageView.snp.makeConstraints { make in
            make.height.equalTo(270)
        }

        headerImageContainer.addArrangedSubview(headerImageView)
        view.addArrangedSubview(headerImageContainer)

        let title = MultilineLabel(
            value: String(key: .REFERRAL_SUCCESS_HEADLINE),
            style: TextStyle.standaloneLargeTitle.colored(UIColor.white).aligned(to: .center)
        )
        bag += view.addArranged(title)

        let description = MultilineLabel(
            value: String(key: .REFERRAL_SUCCESS_BODY),
            style: TextStyle.bodyWhite.aligned(to: .center)
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
            UIColor.darkPurple.withAlphaComponent(0.2).cgColor,
            UIColor.darkPurple.cgColor,
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

        let openReferralsButton = Button(
            title: String(key: .REFERRAL_SUCCESS_BTN_CTA),
            type: .standard(backgroundColor: .purple, textColor: .white)
        )
        bag += buttonsContainer.addArranged(openReferralsButton.wrappedIn(UIStackView())) { stackView in
            stackView.axis = .vertical
            stackView.alignment = .center
        }

        bag += openReferralsButton.onTapSignal.onValue { _ in
            self.didTapOpenReferralsCallbacker.callAll()
        }

        let closeButton = Button(
            title: String(key: .REFERRAL_SUCCESS_BTN_CLOSE),
            type: .pillTransparent(backgroundColor: .blackPurple, textColor: .white)
        )
        bag += buttonsContainer.addArranged(closeButton.wrappedIn(UIStackView())) { stackView in
            stackView.axis = .vertical
            stackView.alignment = .center
        }

        bag += closeButton.onTapSignal.onValue { _ in
            self.didTapCancelCallbacker.callAll()
        }

        bag += scrollView.embedPinned(buttonsContainer, edge: .bottom, minHeight: 70)

        containerView.addArrangedSubview(view)

        return (scrollView, bag)
    }
}

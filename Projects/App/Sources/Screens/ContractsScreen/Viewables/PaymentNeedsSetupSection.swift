//
//  PaymentNeedsSetupSection.swift
//  ugglan
//
//  Created by Axel Backlund on 2019-04-15.
//

import Apollo
import Flow
import Form
import Foundation
import UIKit

struct PaymentNeedsSetupSection {
    @Inject var client: ApolloClient
    var presentingViewController: UIViewController
}

extension PaymentNeedsSetupSection: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()

        let wrapper = UIStackView()
        wrapper.isHidden = true
        wrapper.isLayoutMarginsRelativeArrangement = true

        let containerView = UIView()
        containerView.backgroundColor = .secondaryBackground
        containerView.layer.cornerRadius = 8

        let containerStackView = UIStackView()
        containerStackView.axis = .vertical
        containerStackView.spacing = 12
        containerStackView.alignment = .fill
        containerStackView.edgeInsets = UIEdgeInsets(top: 24, left: 24, bottom: 24, right: 24)
        containerStackView.alpha = 0

        containerView.addSubview(containerStackView)

        containerStackView.snp.makeConstraints { make in
            make.height.width.centerX.centerY.equalToSuperview()
        }

        let infoLabel = MultilineLabel(value: L10n.dashboardPaymentSetupInfo, style: TextStyle.bodyOffBlack.centered())
        bag += containerStackView.addArranged(infoLabel)

        let buttonContainer = UIView()
        let connectButton = Button(
            title: L10n.dashboardPaymentSetupButton,
            type: .outline(borderColor: .primaryTintColor, textColor: .primaryTintColor)
        )
        bag += buttonContainer.add(connectButton) { buttonView in
            buttonView.snp.makeConstraints { make in
                make.height.centerY.centerX.equalToSuperview()
            }
        }

        bag += connectButton.onTapSignal.onValue { _ in
            self.presentingViewController.present(
                PaymentSetup(setupType: .initial),
                style: .modally(),
                options: [.defaults, .allowSwipeDismissAlways]
            )
        }

        containerStackView.addArrangedSubview(buttonContainer)

        wrapper.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.trailing.leading.equalToSuperview().inset(16)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        let dataSignal = client.watch(query: MyPaymentQuery())
            .compactMap { $0.data }

        bag += dataSignal.wait(until: wrapper.hasWindowSignal).delay(by: 0.5).animated(style: SpringAnimationStyle.lightBounce()) { data in
            switch data.payinMethodStatus {
            case .active, .pending:
                wrapper.animationSafeIsHidden = true
                containerStackView.alpha = 0
            default:
                wrapper.animationSafeIsHidden = false
                containerStackView.alpha = 1
            }
        }

        return (wrapper, bag)
    }
}

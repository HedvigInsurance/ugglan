//
//  BankIdSign.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-08-12.
//

import Apollo
import Flow
import Form
import Foundation
import Presentation
import UIKit
import Common
import Space
import ComponentKit

struct BankIdSign {
    @Inject var client: ApolloClient
}

enum BankIdSignError: Error {
    case failed
}

extension BankIdSign: Presentable {
    func materialize() -> (UIViewController, Future<Void>) {
        let viewController = UIViewController()
        let bag = DisposeBag()

        let view = UIView()
        viewController.view = view

        let containerStackView = UIStackView()
        containerStackView.axis = .vertical
        containerStackView.alignment = .center

        bag += containerStackView.applySafeAreaBottomLayoutMargin()
        bag += containerStackView.applyPreferredContentSize(on: viewController)

        view.addSubview(containerStackView)

        containerStackView.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
        }

        let containerView = UIStackView()
        containerView.spacing = 15
        containerView.axis = .vertical
        containerView.alignment = .center
        containerView.layoutMargins = UIEdgeInsets(horizontalInset: 15, verticalInset: 24)
        containerView.isLayoutMarginsRelativeArrangement = true
        containerStackView.addArrangedSubview(containerView)

        let headerContainer = UIStackView()
        headerContainer.axis = .vertical
        headerContainer.spacing = 15

        containerView.addArrangedSubview(headerContainer)

        let iconContainerView = UIView()

        iconContainerView.snp.makeConstraints { make in
            make.height.width.equalTo(120)
        }

        let imageView = UIImageView()
        imageView.image = Asset.bankIdLogo.image
        imageView.tintColor = .hedvig(.primaryText)

        iconContainerView.addSubview(imageView)

        imageView.snp.makeConstraints { make in
            make.height.width.equalToSuperview()
        }

        headerContainer.addArrangedSubview(iconContainerView)

        bag += headerContainer.addArranged(LoadingIndicator(showAfter: 0, size: 50).wrappedIn(UIStackView()))

        let statusLabel = MultilineLabel(value: String(key: .SIGN_START_BANKID), style: .rowTitle)
        bag += containerView.addArranged(statusLabel)

        let closeButtonContainer = UIStackView()
        closeButtonContainer.animationSafeIsHidden = true
        containerView.addArrangedSubview(closeButtonContainer)

        let closeButton = Button(title: "Stäng", type: .standard(backgroundColor: .hedvig(.purple), textColor: .hedvig(.white)))
        bag += closeButtonContainer.addArranged(closeButton)

        let statusSignal = client.subscribe(
            subscription: SignStatusSubscription()
        ).compactMap { $0.data?.signStatus?.status }

        bag += statusSignal.compactMap { $0.collectStatus }.skip(first: 1).onValue { collectStatus in
            let statusText: String

            switch collectStatus.code {
            case "noClient", "outstandingTransaction":
                statusText = String(key: .SIGN_START_BANKID)
            case "userSign":
                statusText = String(key: .SIGN_IN_PROGRESS)
            case "userCancel", "cancelled":
                statusText = String(key: .SIGN_CANCELED)
            default:
                statusText = String(key: .SIGN_FAILED_REASON_UNKNOWN)
            }

            statusLabel.styledTextSignal.value = StyledText(text: statusText, style: .rowTitle)
        }

        bag += client.perform(mutation: SignOfferMutation()).valueSignal.compactMap { result in result.data?.signOfferV2.autoStartToken }.onValue { autoStartToken in
            let urlScheme = Bundle.main.urlScheme ?? ""
            guard let url = URL(string: "bankid:///?autostarttoken=\(autoStartToken)&redirect=\(urlScheme)://bankid") else { return }

            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }

        return (viewController, Future { completion in
            bag += closeButton.onTapSignal.onValue {
                completion(.failure(BankIdSignError.failed))
            }

            bag += statusSignal
                .compactMap { $0.signState }
                .filter { state in state == .completed }
                .take(first: 1)
                .onValue { _ in
                    if let fcmToken = ApplicationState.getFirebaseMessagingToken() {
                        UIApplication.shared.appDelegate.registerFCMToken(fcmToken)
                    }

                    completion(.success)
                }

            bag += statusSignal.compactMap { $0 }.onValue { status in
                guard let code = status.collectStatus?.code, let state = status.signState else {
                    return
                }

                if code == "userCancel", state == .failed {
                    bag += Signal(after: 0).animated(style: SpringAnimationStyle.mediumBounce()) { _ in
                        headerContainer.animationSafeIsHidden = true
                        closeButtonContainer.animationSafeIsHidden = false
                        containerStackView.layoutIfNeeded()
                    }
                }

                if code == "expiredTransaction", state == .failed {
                    let alert = Alert<Void>(
                        title: String(key: .BANKID_INACTIVE_TITLE),
                        message: String(key: .BANKID_INACTIVE_MESSAGE),
                        actions: [Alert.Action(title: String(key: .BANKID_INACTIVE_BUTTON), action: { _ in
                            completion(.failure(BankIdSignError.failed))
                        })]
                    )

                    viewController.present(alert)
                }
            }

            return bag
        })
    }
}

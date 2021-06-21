import Apollo
import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI
import hGraphQL

struct SwedishBankIdSign {
    @Inject var state: OfferState
    var quoteIds: [String]
}

enum SwedishBankIdSignError: Error { case failed }

extension SwedishBankIdSign: Presentable {
    func materialize() -> (UIViewController, Future<Void>) {
        let viewController = UIViewController()
        let bag = DisposeBag()

        let view = UIView()
        view.backgroundColor = .brand(.secondaryBackground())
        viewController.view = view

        let containerStackView = UIStackView()
        containerStackView.axis = .vertical
        containerStackView.alignment = .center
        view.addSubview(containerStackView)

        containerStackView.snp.makeConstraints { make in make.leading.trailing.top.equalToSuperview() }

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

        iconContainerView.snp.makeConstraints { make in make.height.width.equalTo(120) }

        let imageView = UIImageView()
        imageView.image = hCoreUIAssets.bankIdLogo.image
        imageView.tintColor = .brand(.primaryText())

        iconContainerView.addSubview(imageView)

        imageView.snp.makeConstraints { make in make.height.width.equalToSuperview() }

        headerContainer.addArrangedSubview(iconContainerView)

        bag += headerContainer.addArranged(LoadingIndicator(showAfter: 0, size: 50).wrappedIn(UIStackView()))

        var statusLabel = MultilineLabel(value: L10n.signStartBankid, style: .brand(.headline(color: .primary)))
        bag += containerView.addArranged(statusLabel)

        let closeButtonContainer = UIStackView()
        closeButtonContainer.animationSafeIsHidden = true
        containerView.addArrangedSubview(closeButtonContainer)

        let closeButton = Button(title: L10n.generalCloseButton, type: .standard(backgroundColor: .purple, textColor: .white))
        bag += closeButtonContainer.addArranged(closeButton)

        return (
            viewController,
            Future { completion in
                bag += closeButton.onTapSignal.onValue { completion(.failure(SwedishBankIdSignError.failed)) }
            
                state.signQuotes(ids: quoteIds).onValue { signEvent in
                    switch signEvent {
                        
                    case let .swedishBankId(autoStartToken, subscription):
                        let urlScheme =  "" // TODO Bundle.main.urlScheme ??
                            guard
                                let url = URL(
                                    string:
                                        "bankid:///?autostarttoken=\(autoStartToken)&redirect=\(urlScheme)://bankid"
                                )
                            else { return }

                            if UIApplication.shared.canOpenURL(url) {
                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                            }
                        
                        bag += subscription.compactMap { $0.signStatus?.status?.collectStatus?.code }.onValue { code in
                            let statusText: String

                            switch code {
                            case "noClient", "outstandingTransaction": statusText = L10n.signStartBankid
                            case "userSign": statusText = L10n.signInProgress
                            case "userCancel", "cancelled": statusText = L10n.signCanceled
                            default: statusText = L10n.signFailedReasonUnknown
                            }

                            statusLabel.value = statusText
                        }
                        
                        bag += subscription.filter { $0.signStatus?.status?.signState == .completed }.onValue { _ in
//                            if let fcmToken = ApplicationState.getFirebaseMessagingToken() {
//                                UIApplication.shared.appDelegate.registerFCMToken(fcmToken)
//                            } TODO

                            completion(.success)
                        }
                                                
                        bag += subscription.compactMap { $0.signStatus?.status }
                            .onValue { status in
                                guard let code = status.collectStatus?.code,
                                    let state = status.signState
                                else { return }

                                if code == "userCancel", state == .failed {
                                    bag += Signal(after: 0)
                                        .animated(style: SpringAnimationStyle.mediumBounce()) {
                                            _ in
                                            headerContainer.animationSafeIsHidden = true
                                            closeButtonContainer.animationSafeIsHidden =
                                                false
                                            containerStackView.layoutIfNeeded()
                                        }
                                }

                                if code == "expiredTransaction", state == .failed {
                                    let alert = Alert<Void>(
                                        title: L10n.bankidInactiveTitle,
                                        message: L10n.bankidInactiveMessage,
                                        actions: [
                                            Alert.Action(
                                                title: L10n.bankidInactiveButton,
                                                action: { _ in
                                                    completion(
                                                        .failure(
                                                            SwedishBankIdSignError
                                                                .failed
                                                        )
                                                    )
                                                }
                                            )
                                        ]
                                    )

                                    viewController.present(alert)
                                }
                            }
                    case .failed:
                        break
                    default:
                        break
                    }
                }

                return bag
            }
        )
    }
}

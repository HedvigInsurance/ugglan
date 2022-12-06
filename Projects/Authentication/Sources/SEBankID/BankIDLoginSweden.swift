import Apollo
import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI
import hGraphQL

public struct BankIDLoginSweden {
    @PresentableStore var store: AuthenticationStore
    
    public init() {
        
    }
}

public enum BankIDLoginSwedenResult {
    case qrCode
    case emailLogin
    case loggedIn
}

extension BankIDLoginSweden {
    enum AutoStartTokenError: Error {
        case failedToGenerate
    }

    enum FailedError: Error {
        case failed
    }
}

extension BankIDLoginSweden: Presentable {
    public func materialize() -> (UIViewController, Signal<BankIDLoginSwedenResult>) {
        let viewController = UIViewController()
        viewController.preferredPresentationStyle = .detented(.large)
        let bag = DisposeBag()

        let view = UIView()
        view.backgroundColor = .brand(.primaryBackground())
        viewController.view = view
        viewController.title = L10n.bankidLoginTitle

        let containerStackView = UIStackView()
        containerStackView.axis = .vertical
        containerStackView.alignment = .center

        view.addSubview(containerStackView)

        containerStackView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
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
        imageView.image = hCoreUIAssets.bankIdLogo.image
        imageView.tintColor = .brand(.primaryText())

        iconContainerView.addSubview(imageView)

        imageView.snp.makeConstraints { make in
            make.height.width.equalToSuperview()
        }

        headerContainer.addArrangedSubview(iconContainerView)

        bag += headerContainer.addArranged(LoadingIndicator(showAfter: 0, size: 50).wrappedIn(UIStackView()))

        var statusLabel = MultilineLabel(value: L10n.signStartBankid, style: .brand(.headline(color: .primary)))
        bag += containerView.addArranged(statusLabel)

        let alternativeLoginContainer = UIStackView()
        containerView.addArrangedSubview(alternativeLoginContainer)

        let alternativeLoginButton = Button(
            title: L10n.buttonLoginAlternativeMethod,
            type: .standard(
                backgroundColor: .brand(.primaryBackground(true)),
                textColor: .brand(.primaryText(true))
            )
        )
        bag += alternativeLoginContainer.addArranged(alternativeLoginButton)

//        let statusSignal =
//            client.subscribe(
//                subscription: GraphQL.AuthStatusSubscription()
//            )
//            .compactMap { $0.authStatus?.status }
//
//        bag += statusSignal.skip(first: 1)
//            .onValue { authStatus in
//                let statusText: String
//
//                switch authStatus {
//                case .initiated:
//                    statusText = L10n.bankIdAuthTitleInitiated
//                case .inProgress:
//                    statusText = L10n.bankIdAuthTitleInitiated
//                case .failed:
//                    statusText = L10n.bankIdAuthTitleInitiated
//                case .success:
//                    statusText = L10n.bankIdAuthTitleInitiated
//                case .__unknown:
//                    statusText = L10n.bankIdAuthTitleInitiated
//                }
//
//                statusLabel.value = statusText
//            }
        
        bag += viewController.view.didMoveToWindowSignal.onFirstValue { _ in
            store.send(.seBankIDStateAction(action: .startSession))
        }

        return (
            viewController,
            Signal { callback in
                bag += store.onAction(.navigationAction(action: .authSuccess), {
                    callback(.loggedIn)
                })
                
                bag += store.stateSignal.compactMap { state in
                    state.seBankIDState.autoStartToken
                }.onValue { autoStartToken in
                    let urlScheme = Bundle.main.urlScheme ?? ""
                    
                    guard
                        let url = URL(
                            string:
                                "bankid:///?autostarttoken=\(autoStartToken)&redirect=\(urlScheme)://bankid"
                        )
                    else {
                        return
                    }

                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(
                            url,
                            options: [:],
                            completionHandler: nil
                        )
                    }
                }
                
                bag += alternativeLoginButton.onTapSignal.onValue { _ in
                    let alert = Alert<Void>(actions: [
                        .init(
                            title: L10n.emailRowTitle,
                            action: {
                                callback(.emailLogin)
                            }
                        ),
                        .init(
                            title: L10n.bankidOnAnotherDevice,
                            action: {
                                callback(.qrCode)
                            }
                        ),
                        .init(
                            title: L10n.alertCancel,
                            style: .cancel,
                            action: {}
                        ),
                    ])

                    viewController.present(
                        alert,
                        style: .sheet(
                            from: alternativeLoginContainer,
                            rect: alternativeLoginContainer.frame
                        )
                    )
                }

//                bag += statusSignal.distinct()
//                    .onValue { authState in
//                        if authState == .success {
//                            callback(.loggedIn)
//                        }
//                    }

                return bag
            }
        )
    }
}

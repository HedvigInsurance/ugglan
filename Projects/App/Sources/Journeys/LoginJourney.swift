import Apollo
import Authentication
import Flow
import Form
import Foundation
import Presentation
import UIKit
import hAnalytics
import hCore
import hCoreUI

public enum AlternativeLoginMethods {
    case email

    public var value: String {
        switch self {
        case .email:
            return "email"
        }
    }

    public var displayName: String {
        switch self {
        case .email:
            return L10n.emailRowTitle
        }
    }
}

extension AppJourney {
    fileprivate static var loginCompleted: some JourneyPresentation {
        AppJourney.loggedIn.onPresent {
            hAnalyticsEvent.loggedIn().send()
        }
    }

    @JourneyBuilder
    fileprivate static var bankIDSweden: some JourneyPresentation {
        let bankIdAppTestUrl = URL(
            string:
                "bankid:///"
        )!

        if UIApplication.shared.canOpenURL(bankIdAppTestUrl) {

            HostingJourney(
                AuthenticationStore.self,
                rootView: BankIDLoginSweden()
            ) { result in
                if case let .bankIdSwedenResultAction(bankIdAction) = result {
                    if case .qrCode = bankIdAction {
                        Journey(BankIDLoginQR()) { result in
                            switch result {
                            case .loggedIn:
                                loginCompleted
                            case .emailLogin:
                                otp(style: .detented(.large, modally: false))
                            case .close:
                                DismissJourney()
                            }
                        }
                        .withJourneyDismissButton
                        .mapJourneyDismissToCancel
                    } else if case .loggedIn = bankIdAction {
                        loginCompleted
                    } else if case .emailLogin = bankIdAction {
                        otp(style: .detented(.large, modally: false))
                    } else if case .close = bankIdAction {
                        PopJourney()
                    }
                } else if case .openAlternativeLogin = result {
                    HostingJourney(
                        rootView: CheckboxPickerScreen<AlternativeLoginMethods>(
                            items: [(object: AlternativeLoginMethods.email, displayName: "")],
                            preSelectedItems: { [] },
                            onSelected: { selectedValue in
                                let store: AuthenticationStore = globalPresentableStoreContainer.get()

                                if selectedValue.first?.displayName == L10n.emailRowTitle {
                                    store.send(.cancel)
                                    store.send(.bankIdSwedenResultAction(action: .emailLogin))
                                } else if selectedValue.first?.displayName == L10n.bankidOnAnotherDevice {
                                    store.send(.cancel)
                                    store.send(.bankIdSwedenResultAction(action: .qrCode))
                                }
                            }
                        )
                    )
                }
            }
            .configureTitle(L10n.bankidLoginTitle)
            .withDismissButton
        } else {
            Journey(
                BankIDLoginQR(),
                style: .detented(.medium, .large)
            ) { result in
                switch result {
                case .loggedIn:
                    loginCompleted
                case .emailLogin:
                    otp(style: .detented(.large, modally: false))
                case .close:
                    DismissJourney()
                }
            }
            .withJourneyDismissButton
            .mapJourneyDismissToCancel
        }
    }

    fileprivate static func otp(style: PresentationStyle = .detented(.large)) -> some JourneyPresentation {
        OTPAuthJourney.login { next in
            switch next {
            case .success:
                loginCompleted
            }
        }
        .setStyle(style)
        .withDismissButton
    }

    @JourneyBuilder static var login: some JourneyPresentation {
        GroupJourney {
            switch hAnalyticsExperiment.loginMethod {
            case .bankIdSweden:
                bankIDSweden
            case .bankIdNorway, .nemId:
                ZignsecAuthJourney.login {
                    loginCompleted
                }
            case .otp:
                otp()
            }
        }
        .onDismiss {
            let authenticationStore: AuthenticationStore = globalPresentableStoreContainer.get()
            authenticationStore.send(.cancel)
        }
    }
}

extension MenuChildAction {
    static var login: MenuChildAction {
        MenuChildAction(identifier: "login")
    }
}

extension MenuChild {
    public static var login: MenuChild {
        MenuChild(
            title: L10n.settingsLoginRow,
            style: .default,
            image: hCoreUIAssets.memberCard.image,
            action: .login
        )
    }
}

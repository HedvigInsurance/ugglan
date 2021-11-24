import Combine
import Flow
import Foundation
import Presentation
import SwiftUI
import hCore
import hCoreUI

public enum DataCollectionAuthenticationResult: Codable {
    case completed
    case failed
}

struct SwedishBankID: View {
    var autoStartToken: String?

    func openBankIDApp() {
        guard let autoStartToken = autoStartToken else {
            return
        }

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

    var body: some View {
        VStack(spacing: 25) {
            hCoreUIAssets.bankIdLogo.view.resizable()
                .frame(
                    width: 48,
                    height: 48,
                    alignment: .center
                )
                .onReceive(Just(autoStartToken)) { _ in
                    openBankIDApp()
                }
            hText(L10n.bankIdAuthTitleInitiated, style: .title3)
        }
    }
}

struct NorwegianBankIDWords: View {
    var words: String

    var body: some View {
        VStack(spacing: 15) {
            hText("Enter these words", style: .title2)
            hText(words, style: .headline)
        }
    }
}

struct AuthMethodContainer: View {
    @PresentableStore var store: DataCollectionStore
    var authMethod: DataCollectionAuthMethod?

    var body: some View {
        PresentableStoreLens(
            DataCollectionStore.self,
            getter: { state in
                state.status
            }
        ) { status in
            if status == .login {
                switch authMethod {
                case .swedishBankIDEphemeral:
                    SwedishBankID(autoStartToken: nil)
                case let .swedishBankIDAutoStartToken(token):
                    SwedishBankID(autoStartToken: token)
                case let .norwegianBankIDWords(words):
                    NorwegianBankIDWords(words: words)
                case .none:
                    ActivityIndicator(style: .medium)
                }
            } else {
                ActivityIndicator(style: .medium)
                    .onReceive(Just(status)) { status in
                        if status == .collecting {
                            store.send(.confirmResult(result: .started))
                        } else if status == .failed {
                            store.send(.confirmResult(result: .failed))
                        }
                    }
            }
        }
    }
}

public struct DataCollectionAuthentication: View {
    public init() {}

    @PresentableStore var store: DataCollectionStore

    public var body: some View {
        PresentableStoreLens(
            DataCollectionStore.self,
            getter: { state in
                state.authMethod
            }
        ) { authMethod in
            AuthMethodContainer(authMethod: authMethod)
        }
        .presentableStoreLensAnimation(.easeInOut(duration: 0.5))
    }
}

extension DataCollectionAuthentication {
    static func journey<InnerJourney: JourneyPresentation>(
        style: PresentationStyle = .default,
        @JourneyBuilder _ next: @escaping (_ result: DataCollectionConfirmationResult) -> InnerJourney
    ) -> some JourneyPresentation {
        HostingJourney(
            DataCollectionStore.self,
            rootView: DataCollectionAuthentication(),
            style: style
        ) { action in
            switch action {
            case let .confirmResult(result):
                next(result)
            default:
                ContinueJourney()
            }
        }
        .configureTitle(L10n.Insurely.title)
        .withDismissButton
    }
}

struct DataCollectionAuthenticationPreview: PreviewProvider {
    static var previews: some View {
        Group {
            JourneyPreviewer(
                DataCollectionAuthentication.journey(style: .detented(.large)) { _ in
                    ContinueJourney()
                }
            )
            .preferredColorScheme(.light)
            JourneyPreviewer(
                DataCollectionAuthentication.journey(style: .detented(.large)) { _ in
                    ContinueJourney()
                }
            )
            .preferredColorScheme(.dark)
        }
        .mockProvider()
    }
}

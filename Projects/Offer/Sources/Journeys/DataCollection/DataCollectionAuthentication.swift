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

    @State var hasOpenedBankID = false
    @State var showLoader = false

    func openBankIDApp() {
        guard !hasOpenedBankID else {
            return
        }

        self.hasOpenedBankID = true

        let urlScheme = Bundle.main.urlScheme ?? ""

        guard let autoStartToken = autoStartToken else {
            guard
                let url = URL(
                    string:
                        "bankid:///?redirect=\(urlScheme)://bankid"
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
                showLoader = true
            }

            return
        }

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

            showLoader = true
        }
    }

    private func showLoaderAfterDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 7) {
            withAnimation(.easeInOut) {
                showLoader = true
            }
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
                .onAppear {
                    showLoaderAfterDelay()
                }
            if showLoader {
                ActivityIndicator(style: .medium)
            } else {
                hText(L10n.bankIdAuthTitleInitiated, style: .title3)
            }
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
    var session: DataCollectionSession

    var body: some View {
        if session.status == .login {
            switch session.authMethod {
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
                .onReceive(Just(session.status)) { status in
                    if status == .collecting || status == .completed {
                        store.send(.session(id: session.id, action: .confirmResult(result: .started)))
                    } else if status == .failed {
                        store.send(.session(id: session.id, action: .confirmResult(result: .failed)))
                    }
                }
        }
    }
}

public struct DataCollectionAuthentication: View {
    public init() {}

    @PresentableStore var store: DataCollectionStore

    public var body: some View {
        ReadDataCollectionSession { session in
            AuthMethodContainer(session: session)
        }
        .presentableStoreLensAnimation(.easeInOut(duration: 0.5))
    }
}

extension DataCollectionAuthentication {
    static func journey<InnerJourney: JourneyPresentation>(
        style: PresentationStyle = .default,
        sessionID: UUID,
        @JourneyBuilder _ next: @escaping (_ result: DataCollectionConfirmationResult) -> InnerJourney
    ) -> some JourneyPresentation {
        HostingJourney(
            DataCollectionStore.self,
            rootView: DataCollectionAuthentication()
                .environment(\.dataCollectionSessionID, sessionID),
            style: style
        ) { action in
            switch action {
            case .session(id: sessionID, action: .confirmResult(let result)):
                next(result)
            default:
                ContinueJourney()
            }
        }
        .configureTitle(L10n.Insurely.title)
        .withJourneyDismissButton
    }
}

struct DataCollectionAuthenticationPreview: PreviewProvider {
    static var previews: some View {
        Group {
            JourneyPreviewer(
                DataCollectionAuthentication.journey(style: .detented(.large), sessionID: UUID()) { _ in
                    ContinueJourney()
                }
            )
            .preferredColorScheme(.light)
            JourneyPreviewer(
                DataCollectionAuthentication.journey(style: .detented(.large), sessionID: UUID()) { _ in
                    ContinueJourney()
                }
            )
            .preferredColorScheme(.dark)
        }
        .mockProvider()
    }
}

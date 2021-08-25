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
    
    var body: some View {
        hCoreUIAssets.bankIdLogo.view.resizable().frame(
            width: 48,
            height: 48,
            alignment: .center
        )
    }
}

struct NorwegianBankIDWords: View {
    var words: String
    
    var body: some View {
        VStack(spacing: 10) {
            hText("Enter these words", style: .title2)
            hText(words, style: .headline)
        }
    }
}

public struct DataCollectionAuthentication: View {
    public init() {}

    @PresentableStore var store: DataCollectionStore
    
    public var body: some View {
        hForm {
            hSection {
                PresentableStoreLens(
                    DataCollectionStore.self,
                    getter: { state in
                        state.authMethod ?? nil
                    }
                ) { authMethod in
                    switch authMethod {
                    case .swedishBankIDEphemeral:
                        SwedishBankID(autoStartToken: nil)
                    case let .swedishBankIDAutoStartToken(token):
                        SwedishBankID(autoStartToken: token)
                    case let .norwegianBankIDWords(words):
                        NorwegianBankIDWords(words: words)
                    case .none:
                        ActivityIndicator(isAnimating: true)
                    }
                }.transition(.scale)
            }
            .sectionContainerStyle(.transparent)
        }
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

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

public struct DataCollectionAuthentication: View {
    public init() {}

    @PresentableStore var store: DataCollectionStore

    public var body: some View {
        hForm {
            hSection {
                hCoreUIAssets.bankIdLogo.view.frame(
                    width: 48,
                    height: 48,
                    alignment: .center
                )
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

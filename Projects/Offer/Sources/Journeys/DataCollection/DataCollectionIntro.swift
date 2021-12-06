import Flow
import Foundation
import Presentation
import SwiftUI
import hCore
import hCoreUI

public enum DataCollectionIntroDecision: Codable {
    case accept
    case decline
}

public struct DataCollectionIntro: View {
    public init() {}

    @PresentableStore var store: DataCollectionStore

    public var body: some View {
        hForm {
            hSection {
                VStack(alignment: .leading, spacing: 16) {
                    L10n.InsurelyIntro.title(store.state.providerDisplayName ?? "")
                        .hText(.title2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    L10n.InsurelyIntro.description
                        .hText(.body)
                        .foregroundColor(hLabelColor.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                VStack(spacing: 16) {
                    hButton.LargeButtonFilled {
                        store.send(.didIntroDecide(decision: .accept))
                    } content: {
                        L10n.InsurelyIntro.continueButtonText.hText()
                    }

                    hButton.LargeButtonOutlined {
                        store.send(.didIntroDecide(decision: .decline))
                    } content: {
                        L10n.InsurelyIntro.skipButtonText.hText()
                    }
                }
                .padding(.top, 40)
            }
            .sectionContainerStyle(.transparent)
        }
    }
}

extension DataCollectionIntro {
    static func journey<InnerJourney: JourneyPresentation>(
        style: PresentationStyle = .detented(.large),
        @JourneyBuilder _ next: @escaping (_ decision: DataCollectionIntroDecision) -> InnerJourney
    ) -> some JourneyPresentation {
        HostingJourney(
            DataCollectionStore.self,
            rootView: DataCollectionIntro(),
            style: style
        ) { action in
            switch action {
            case let .didIntroDecide(decision):
                next(decision)
            default:
                ContinueJourney()
            }
        }
        .configureTitle(L10n.Insurely.title)
        .withDismissButton
    }
}

struct DataCollectionIntroPreview: PreviewProvider {
    static var previews: some View {
        Group {
            JourneyPreviewer(
                DataCollectionIntro.journey { _ in
                    ContinueJourney()
                }
            )
            .preferredColorScheme(.light)
            JourneyPreviewer(
                DataCollectionIntro.journey { _ in
                    ContinueJourney()
                }
            )
            .preferredColorScheme(.dark)
        }
        .mockProvider()
    }
}

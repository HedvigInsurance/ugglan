import Flow
import Foundation
import Presentation
import SwiftUI
import hCore
import hCoreUI

public enum DataCollectionConfirmationResult: Codable {
    case completed
    case failed
    case retry

    #if compiler(<5.5)
        public func encode(to encoder: Encoder) throws {
            #warning("Waiting for automatic codable conformance from Swift 5.5, remove this when we have upgraded XCode")
            fatalError()
        }

        public init(
            from decoder: Decoder
        ) throws {
            #warning("Waiting for automatic codable conformance from Swift 5.5, remove this when we have upgraded XCode")
            fatalError()
        }
    #endif
}

public struct DataCollectionConfirmation: View {
    var wasConfirmed: Bool

    public init(
        wasConfirmed: Bool
    ) {
        self.wasConfirmed = wasConfirmed
    }

    @PresentableStore var store: DataCollectionStore

    var title: String {
        if wasConfirmed {
            return L10n.InsurelyConfirmation.title
        }

        return L10n.InsurelyFailure.title
    }

    var description: String {
        if wasConfirmed {
            return L10n.InsurelyConfirmation.description
        }

        return L10n.InsurelyFailure.description(store.state.providerDisplayName ?? "")
    }

    public var body: some View {
        hForm {
            hSection {
                VStack(alignment: .leading, spacing: 16) {
                    hCoreUIAssets.circularCheckmark.view
                        .frame(width: 30, height: 30, alignment: .leading)
                    title
                        .hText(.title1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    description
                        .hText(.body)
                        .foregroundColor(hLabelColor.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                VStack(spacing: 16) {
                    if wasConfirmed {
                        hButton.LargeButtonFilled {
                            store.send(.confirmResult(result: .completed))
                        } content: {
                            L10n.InsurelyConfirmation.continueButtonText.hText()
                        }
                    } else {
                        hButton.LargeButtonFilled {
                            store.send(.confirmResult(result: .retry))
                        } content: {
                            L10n.InsurelyFailure.retryButtonText.hText()
                        }
                        hButton.LargeButtonOutlined {
                            store.send(.confirmResult(result: .failed))
                        } content: {
                            L10n.InsurelyFailure.skipButtonText.hText()
                        }
                    }
                }
                .padding(.top, 40)
            }
            .sectionContainerStyle(.transparent)
        }
    }
}

extension DataCollectionConfirmation {
    static func journey<InnerJourney: JourneyPresentation>(
        wasConfirmed: Bool,
        @JourneyBuilder _ next: @escaping (_ result: DataCollectionConfirmationResult) -> InnerJourney
    ) -> some JourneyPresentation {
        HostingJourney(
            DataCollectionStore.self,
            rootView: DataCollectionConfirmation(
                wasConfirmed: wasConfirmed
            ),
            style: .detented(.large)
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

struct DataCollectionConfirmationPreview: PreviewProvider {
    static var previews: some View {
        Group {
            JourneyPreviewer(
                DataCollectionConfirmation.journey(wasConfirmed: true) { _ in
                    ContinueJourney()
                }
            )
            .preferredColorScheme(.light)
            JourneyPreviewer(
                DataCollectionConfirmation.journey(wasConfirmed: false) { _ in
                    ContinueJourney()
                }
            )
            .preferredColorScheme(.dark)
        }
        .mockProvider()
    }
}

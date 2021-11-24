import Flow
import Foundation
import Presentation
import SwiftUI
import hCore
import hCoreUI

public enum DataCollectionConfirmationResult: Codable {
    case started
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
                            store.send(.confirmResult(result: .started))
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
    static func journey(
        style: PresentationStyle = .default,
        wasConfirmed: Bool,
        onComplete: @escaping (_ id: UUID?, _ personalNumber: String?) -> Void
    ) -> some JourneyPresentation {
        HostingJourney(
            DataCollectionStore.self,
            rootView: DataCollectionConfirmation(
                wasConfirmed: wasConfirmed
            ),
            style: style
        ) { action in
            switch action {
            case let .confirmResult(result):
                switch result {
                case .started:
                    DismissJourney()
                        .onPresent {
                            let store: DataCollectionStore = globalPresentableStoreContainer.get()
                            
                            if case let .personalNumber(personalNumber) = store.state.credential {
                                onComplete(
                                    store.state.id,
                                    personalNumber
                                )
                            } else {
                                onComplete(
                                    store.state.id,
                                    nil
                                )
                            }                            
                        }
                case .failed:
                    DismissJourney()
                case .retry:
                    DataCollection.journey(
                        onComplete: onComplete
                    )
                }
            default:
                ContinueJourney()
            }
        }
        .configureTitle(L10n.Insurely.title)
    }
}

struct DataCollectionConfirmationPreview: PreviewProvider {
    static var previews: some View {
        Group {
            JourneyPreviewer(
                DataCollectionConfirmation.journey(style: .detented(.large), wasConfirmed: true) { _, _ in

                }
            )
            .preferredColorScheme(.light)
            JourneyPreviewer(
                DataCollectionConfirmation.journey(style: .detented(.large), wasConfirmed: false) { _, _ in

                }
            )
            .preferredColorScheme(.dark)
        }
        .mockProvider()
    }
}

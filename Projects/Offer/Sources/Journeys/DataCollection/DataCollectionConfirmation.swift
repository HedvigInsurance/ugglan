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

    func description(_ session: DataCollectionSession) -> String {
        if wasConfirmed {
            return L10n.InsurelyConfirmation.description
        }

        return L10n.InsurelyFailure.description(session.providerDisplayName ?? "")
    }

    public var body: some View {
        ReadDataCollectionSession { session in
            hForm {
                hSection {
                    VStack(alignment: .leading, spacing: 16) {
                        hCoreUIAssets.circularCheckmark.view
                            .frame(width: 30, height: 30, alignment: .leading)
                        title
                            .hText(.title1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        description(session)
                            .hText(.body)
                            .foregroundColor(hLabelColor.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    VStack(spacing: 16) {
                        if wasConfirmed {
                            hButton.LargeButtonFilled {
                                store.send(.session(id: session.id, action: .confirmResult(result: .started)))
                            } content: {
                                L10n.InsurelyConfirmation.continueButtonText.hText()
                            }
                        } else {
                            hButton.LargeButtonFilled {
                                store.send(.removeSession(id: session.id))
                                store.send(.session(id: session.id, action: .confirmResult(result: .retry)))
                            } content: {
                                L10n.InsurelyFailure.retryButtonText.hText()
                            }
                            hButton.LargeButtonOutlined {
                                store.send(.session(id: session.id, action: .confirmResult(result: .failed)))
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
}

extension DataCollectionConfirmation {
    static func journey(
        style: PresentationStyle = .default,
        sessionID: UUID,
        wasConfirmed: Bool,
        onComplete: @escaping (_ id: UUID?, _ personalNumber: String?) -> Void
    ) -> some JourneyPresentation {
        HostingJourney(
            DataCollectionStore.self,
            rootView: DataCollectionConfirmation(
                wasConfirmed: wasConfirmed
            )
            .environment(\.dataCollectionSessionID, sessionID),
            style: style
        ) { action in
            switch action {
            case let .session(id: sessionID, action: .confirmResult(result)):
                switch result {
                case .started:
                    DismissJourney()
                        .onPresent {
                            let store: DataCollectionStore = globalPresentableStoreContainer.get()

                            if let session = store.state.sessionFor(sessionID) {
                                if case let .personalNumber(personalNumber) = session.credential {
                                    onComplete(
                                        session.id,
                                        personalNumber
                                    )
                                } else {
                                    onComplete(
                                        session.id,
                                        nil
                                    )
                                }
                            }
                        }
                case .failed:
                    DismissJourney()
                        .onPresent {
                            onComplete(
                                nil,
                                nil
                            )
                        }
                case .retry:
                    let store: DataCollectionStore = globalPresentableStoreContainer.get()
                    let session = store.state.sessionFor(sessionID)

                    DataCollection.journey(
                        providerID: session?.providerID ?? "",
                        providerDisplayName: session?.providerDisplayName ?? "",
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
                DataCollectionConfirmation.journey(style: .detented(.large), sessionID: UUID(), wasConfirmed: true) {
                    _,
                    _ in

                }
            )
            .preferredColorScheme(.light)
            JourneyPreviewer(
                DataCollectionConfirmation.journey(style: .detented(.large), sessionID: UUID(), wasConfirmed: false) {
                    _,
                    _ in

                }
            )
            .preferredColorScheme(.dark)
        }
        .mockProvider()
    }
}

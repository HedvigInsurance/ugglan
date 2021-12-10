import Flow
import Foundation
import Presentation
import hCore

public enum DataCollection {
    static func journey(
        style: PresentationStyle = .default,
        sessionID: UUID,
        onComplete: @escaping (_ id: UUID?, _ personalNumber: String?) -> Void
    ) -> some JourneyPresentation {
        DataCollectionIntro.journey(style: style, sessionID: sessionID) { decision in
            switch decision {
            case .accept:
                DataCollectionPersonalIdentity.journey(sessionID: sessionID) {
                    DataCollectionAuthentication.journey(sessionID: sessionID) { result in
                        DataCollectionConfirmation.journey(
                            sessionID: sessionID,
                            wasConfirmed: result == .started,
                            onComplete: onComplete
                        )
                        .hidesBackButton
                    }
                    .hidesBackButton
                }
            case .decline:
                PopJourney()
                    .onPresent {
                        onComplete(nil, nil)
                    }
            }
        }
    }

    @JourneyBuilder public static func journey(
        providerID: String,
        providerDisplayName: String,
        onComplete: @escaping (_ id: UUID?, _ personalNumber: String?) -> Void
    ) -> some JourneyPresentation {
        let store: DataCollectionStore = globalPresentableStoreContainer.get()
       
        let existingSession = store.state.sessions.first { session in
            session.providerID == providerID
        }
        
        if let existingSession = existingSession {
            ContinueJourney().onPresent {
                onComplete(existingSession.id, nil)
            }
        } else {
            let sessionID = UUID()

            journey(
                style: .detented(.large),
                sessionID: sessionID,
                onComplete: onComplete
            )
            .addConfiguration { presenter in
                let store: DataCollectionStore = globalPresentableStoreContainer.get()
                store.send(.startSession(id: sessionID, providerID: providerID, providerDisplayName: providerDisplayName))
            }
            .onError { _ in
                store.send(.removeSession(id: sessionID))
            }
        }
    }
}

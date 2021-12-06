import Flow
import Foundation
import Presentation
import hCore

public enum DataCollection {
    static func journey(
        style: PresentationStyle = .default,
        onComplete: @escaping (_ id: UUID?, _ personalNumber: String?) -> Void
    ) -> some JourneyPresentation {
        DataCollectionIntro.journey(style: style) { decision in
            switch decision {
            case .accept:
                DataCollectionPersonalIdentity.journey {
                    DataCollectionAuthentication.journey { result in
                        DataCollectionConfirmation.journey(
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

    public static func journey(
        providerID: String,
        providerDisplayName: String,
        onComplete: @escaping (_ id: UUID?, _ personalNumber: String?) -> Void
    ) -> some JourneyPresentation {
        journey(
            style: .detented(.large),
            onComplete: onComplete
        )
        .addConfiguration { presenter in
            let store: DataCollectionStore = globalPresentableStoreContainer.get()
            store.send(.setProvider(providerID: providerID, providerDisplayName: providerDisplayName))
        }
    }
}

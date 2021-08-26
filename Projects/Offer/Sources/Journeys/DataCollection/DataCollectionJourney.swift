import Flow
import Foundation
import Presentation
import hCore

public enum DataCollection {
    public static func journey(provider: String) -> some JourneyPresentation {
        DataCollectionIntro.journey { decision in
            switch decision {
            case .accept:
                DataCollectionPersonalIdentity.journey {
                    DataCollectionAuthentication.journey { result in
                        DataCollectionConfirmation.journey(
                            wasConfirmed: result == .completed
                        ) { result in
                            ContinueJourney()
                        }
                    }
                }
            case .decline:
                PopJourney()
            }
        }.addConfiguration { presenter in
            let store: DataCollectionStore = globalPresentableStoreContainer.get()
            store.send(.setProvider(provider: provider))
        }
    }
}

import Flow
import Foundation
import Presentation
import hCore

public enum DataCollection {
    public static func journey(
        provider: String,
        onComplete: @escaping (_ id: UUID?) -> Void
    ) -> some JourneyPresentation {
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
                .onPresent {
                    let store: DataCollectionStore = globalPresentableStoreContainer.get()
                    onComplete(store.state.id)
                }
            case .decline:
                PopJourney()
                    .onPresent {
                        let store: DataCollectionStore = globalPresentableStoreContainer.get()
                        onComplete(store.state.id)
                    }
            }
        }
        .addConfiguration { presenter in
            let store: DataCollectionStore = globalPresentableStoreContainer.get()
            store.send(.setProvider(provider: provider))
        }
    }
}

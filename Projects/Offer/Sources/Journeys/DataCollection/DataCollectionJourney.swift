import Flow
import Foundation
import Presentation
import hCore

public enum DataCollection {
    public static func journey(
        providerID: String,
        providerDisplayName: String,
        onComplete: @escaping (_ id: UUID?) -> Void
    ) -> some JourneyPresentation {
        DataCollectionIntro.journey { decision in
            switch decision {
            case .accept:
                DataCollectionPersonalIdentity.journey {
                    DataCollectionAuthentication.journey { result in
                        DataCollectionConfirmation.journey(
                            wasConfirmed: result == .started
                        ) { result in
                            switch result {
                            case .started, .failed:
                                DismissJourney()
                            case .retry:
                                PopJourney().onPresent {
                                    let store: DataCollectionStore = globalPresentableStoreContainer.get()
                                    store.send(.retryAuthentication)
                                }
                            }
                        }.hidesBackButton
                    }.hidesBackButton
                }
                .onPresent {
                    let store: DataCollectionStore = globalPresentableStoreContainer.get()
                    onComplete(store.state.id)
                }
            case .decline:
                PopJourney()
                    .onPresent {
                        onComplete(nil)
                    }
            }
        }
        .addConfiguration { presenter in
            let store: DataCollectionStore = globalPresentableStoreContainer.get()
            store.send(.setProvider(providerID: providerID, providerDisplayName: providerDisplayName))
        }
    }
}

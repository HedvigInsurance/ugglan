import Contracts
import EditCoInsured
import Presentation

extension AppJourney {
    @JourneyBuilder
    static func editCoInsured(configs: [InsuredPeopleConfig]) -> some JourneyPresentation {
        EditCoInsuredJourney.openInitialScreen(configs: configs)
            .onDismiss {
                let contractStore: ContractStore = globalPresentableStoreContainer.get()
                contractStore.send(.fetch)
            }
    }
}

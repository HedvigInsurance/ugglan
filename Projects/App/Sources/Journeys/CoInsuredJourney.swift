import Contracts
import Presentation

extension AppJourney {
    @JourneyBuilder
    static func editCoInsured(configs: [InsuredPeopleConfig]) -> some JourneyPresentation {
        EditCoInsuredJourney.openInitialScreen(configs: configs)
    }
}

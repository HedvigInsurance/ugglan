import Contracts
import Presentation
import EditCoInsured

extension AppJourney {
    @JourneyBuilder
    static func editCoInsured(configs: [InsuredPeopleConfig]) -> some JourneyPresentation {
        EditCoInsuredJourney.openInitialScreen(configs: configs)
    }
}

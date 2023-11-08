import Contracts
import Presentation

extension AppJourney {
    @JourneyBuilder
    static func editCoInsured(contractIds: [String]) -> some JourneyPresentation {
        EditCoInsuredJourney.openInitialScreen(contractIds: contractIds)
    }
}

import Presentation
import Contracts

extension AppJourney {
    @JourneyBuilder
    static func editCoInsured(contractIds: [String]) -> some JourneyPresentation {
        if contractIds.count > 1 {
            EditCoInsuredJourney.openSelectInsurance(contractIds: contractIds)
        } else {
            EditCoInsuredJourney.openNewInsuredPeopleScreen(id: contractIds.first ?? "")
        }
    }
}

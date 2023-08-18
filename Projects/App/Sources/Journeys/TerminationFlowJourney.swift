import Foundation
import Presentation
import TerminateContracts

extension AppJourney {
    @JourneyBuilder
    static func startTerminationJourney() -> some JourneyPresentation {
        TerminationFlowJourney.getScreen(for: .navigationAction(action: .openSetTerminationDateScreen))
    }
}

import Foundation
import Presentation
import TerminateContracts

extension AppJourney {
    @JourneyBuilder
    static func startTerminationJourney(action: TerminationNavigationAction) -> some JourneyPresentation {
        TerminationFlowJourney.getScreen(for: .navigationAction(action: action))
    }
}

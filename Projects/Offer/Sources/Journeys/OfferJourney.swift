import Foundation
import Presentation

extension Offer {
    public var journey: some JourneyPresentation {
        Journey(self) { value in
            value
        }
    }
}

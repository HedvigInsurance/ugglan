import Flow
import Foundation
import Presentation
import hCore

public enum DataCollection {
    public static var journey: some JourneyPresentation {
        DataCollectionIntro.journey { decision in
            switch decision {
            case .accept:
                DataCollectionPersonalIdentity.journey()
            case .decline:
                PopJourney()
            }
        }
    }
}

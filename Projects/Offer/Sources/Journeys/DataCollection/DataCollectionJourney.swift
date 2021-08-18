//
//  Journey.swift
//  Offer
//
//  Created by Sam Pettersson on 2021-08-17.
//  Copyright © 2021 Hedvig AB. All rights reserved.
//

import Foundation
import Presentation
import Flow
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

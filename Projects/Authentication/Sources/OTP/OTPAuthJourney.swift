//
//  OTPAuthJourney.swift
//  Authentication
//
//  Created by Sam Pettersson on 2021-11-14.
//  Copyright © 2021 Hedvig AB. All rights reserved.
//

import Foundation
import Presentation
import hCore

public struct OTPAuthJourney {
    public static var journey: some JourneyPresentation {
        HostingJourney(
            AuthenticationStore.self,
            rootView: OTPEmailEntry()
        ) { action in
            if case .navigationAction(action: .otpCode) = action {
                HostingJourney(
                    AuthenticationStore.self,
                    rootView: OTPCodeEntry()
                ) { action in
                    ContinueJourney()
                }
            }
        }
    }
}

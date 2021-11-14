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

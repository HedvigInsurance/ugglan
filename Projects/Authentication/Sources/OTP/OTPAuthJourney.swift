import Presentation
import SwiftUI
import hCore
import hCoreUI

public enum OTPAuthJourneyNext {
    case success
}

public struct OTPAuthJourney {
    public static func login<Next: JourneyPresentation>(
        @JourneyBuilder _ next: @escaping (_ next: OTPAuthJourneyNext) -> Next
    ) -> some JourneyPresentation {
        let store: AuthenticationStore = globalPresentableStoreContainer.get()
        return HostingJourney(
            AuthenticationStore.self,
            rootView: OTPEntryView(otpVM: store.otpState)
        ) { action in
            if case .navigationAction(action: .otpCode) = action {
                HostingJourney(
                    AuthenticationStore.self,
                    rootView: OTPCodeEntryView(otpVM: store.otpState)
                ) { action in
                    if case .navigationAction(action: .authSuccess) = action {
                        next(.success).hidesBackButton
                    }
                }
            }
        }
        .onPresent {
            let store: AuthenticationStore = globalPresentableStoreContainer.get()
            store.otpState.reset()
        }
    }
}

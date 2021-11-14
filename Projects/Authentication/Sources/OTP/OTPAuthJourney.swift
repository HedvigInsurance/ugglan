import Foundation
import Presentation
import hCore

public struct OTPAuthJourney {
    public static func login<Next: JourneyPresentation>(
        @JourneyBuilder _ next: @escaping (_ accessToken: String) -> Next
    ) -> some JourneyPresentation {
        HostingJourney(
            AuthenticationStore.self,
            rootView: OTPEmailEntry()
        ) { action in
            if case .navigationAction(action: .otpCode) = action {
                HostingJourney(
                    AuthenticationStore.self,
                    rootView: OTPCodeEntry()
                ) { action in
                    if case let .navigationAction(action: .authSuccess(accessToken)) = action {
                        next(accessToken)
                    }
                }
            }
        }
        .onPresent {
            let store: AuthenticationStore = globalPresentableStoreContainer.get()
            store.send(.otpStateAction(action: .reset))
        }
        .withDismissButton
    }
}

import Flow
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI

public enum OTPAuthJourneyNext {
    case success
}

public struct OTPAuthJourney {
    public static func loginEmail<Next: JourneyPresentation>(
        @JourneyBuilder _ next: @escaping (_ next: OTPAuthJourneyNext) -> Next
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
                    if case .navigationAction(action: .authSuccess) = action {
                        next(.success).hidesBackButton
                    }
                }
            }
        }
        .onPresent {
            let store: AuthenticationStore = globalPresentableStoreContainer.get()
            store.send(.otpStateAction(action: .reset))
        }
    }
    
    public static func loginSSN<Next: JourneyPresentation>(
        @JourneyBuilder _ next: @escaping (_ next: OTPAuthJourneyNext) -> Next
    ) -> some JourneyPresentation {
        HostingJourney(
            AuthenticationStore.self,
            rootView: OTPSSNEntry()
        ) { action in
            if case .navigationAction(action: .otpCode) = action {
                HostingJourney(
                    AuthenticationStore.self,
                    rootView: OTPCodeEntry()
                ) { action in
                    if case .navigationAction(action: .authSuccess) = action {
                        next(.success).hidesBackButton
                    }
                }
            }
        }
        .onPresent {
            let store: AuthenticationStore = globalPresentableStoreContainer.get()
            store.send(.otpStateAction(action: .reset))
        }
    }
}

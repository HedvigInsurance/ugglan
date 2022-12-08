import Foundation
import Presentation
import hCore
import hCoreUI

public struct ZignsecAuthJourney {
    public static func login<Next: JourneyPresentation>(
        @JourneyBuilder _ next: @escaping () -> Next
    ) -> some JourneyPresentation {
        HostingJourney(
            AuthenticationStore.self,
            rootView: ZignsecCredentialEntry()
        ) { action in
            if case .navigationAction(action: .zignsecWebview) = action {
                HostingJourney(
                    AuthenticationStore.self,
                    rootView: ZignsecWebview()
                ) { action in
                    if case .navigationAction(action: .authSuccess) = action {
                        next().hidesBackButton
                    }
                }
                .onDismiss {
                    let store: AuthenticationStore = globalPresentableStoreContainer.get()
                    store.send(.cancel)
                }
            }
        }
        .onPresent {
            let store: AuthenticationStore = globalPresentableStoreContainer.get()
            store.send(.zignsecStateAction(action: .reset))
        }
    }
}

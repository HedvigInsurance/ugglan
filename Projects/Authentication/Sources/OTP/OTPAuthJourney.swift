import Flow
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI

public enum OTPAuthJourneyNext {
    case success
    case chat
}

public struct OTPAuthJourney {
    public static func login<Next: JourneyPresentation>(
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
                    if case let .navigationAction(action: .authSuccess) = action {
                        next(.success).hidesBackButton
                    } else if case .navigationAction(action: .chat) = action {
                        next(.chat)
                    }
                }
                .addConfiguration { presenter in
                    let barButtonItem = UIBarButtonItem(
                        title: L10n.Login.NavigationBar.RightElement.help
                    )

                    presenter.bag += barButtonItem.onValue { _ in
                        let store: AuthenticationStore = globalPresentableStoreContainer.get()
                        store.send(.navigationAction(action: .chat))
                    }

                    presenter.viewController.navigationItem.rightBarButtonItem = barButtonItem
                }
            }
        }
        .onPresent {
            let store: AuthenticationStore = globalPresentableStoreContainer.get()
            store.send(.otpStateAction(action: .reset))
        }
    }
}

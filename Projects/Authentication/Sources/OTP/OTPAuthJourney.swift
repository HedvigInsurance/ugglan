import Foundation
import Presentation
import hCore
import UIKit
import hCoreUI
import Flow

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
                        next(accessToken).hidesBackButton
                    }
                }.addConfiguration { presenter in
                    let barButtonItem = UIBarButtonItem(
                        title: L10n.Login.NavigationBar.RightElement.help
                    )
                    
                    presenter.bag += barButtonItem.onValue { _ in
                        ChatButton.openChatHandler(presenter.viewController)
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

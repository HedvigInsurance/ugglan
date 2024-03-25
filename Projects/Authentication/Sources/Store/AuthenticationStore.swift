import Apollo
import Flow
import Foundation
import Presentation
import SwiftUI
import hCore
import hCoreUI

enum LoginStatus: Equatable {
    case pending(statusMessage: String?)
    case completed(code: String)
    case failed(message: String?)
    case unknown
}

public final class AuthenticationStore: StateStore<AuthenticationState, AuthenticationAction> {
    @Inject var authentificationService: AuthentificationService
    let otpState = OTPState()
    public override func effects(
        _ getState: @escaping () -> AuthenticationState,
        _ action: AuthenticationAction
    ) async {
        if case .navigationAction(action: .authSuccess) = action {
            Task {
                let generator = await UINotificationFeedbackGenerator()
                await generator.notificationOccurred(.success)
            }
            send(.bankIdQrResultAction(action: .loggedIn))
        } else if case .logout = action {
            do {
                try await authentificationService.logout()
                send(.logoutSuccess)
            } catch _ {
                send(.logoutFailure)
            }
        }
    }

    public override func reduce(_ state: AuthenticationState, _ action: AuthenticationAction) -> AuthenticationState {
        return state
    }

}

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

    public override func effects(
        _ getState: @escaping () -> AuthenticationState,
        _ action: AuthenticationAction
    ) async {
        if case .logout = action {
            do {
                try await authentificationService.logout()
            } catch _ {
            }
        }
    }

    public override func reduce(_ state: AuthenticationState, _ action: AuthenticationAction) -> AuthenticationState {
        return state
    }

}

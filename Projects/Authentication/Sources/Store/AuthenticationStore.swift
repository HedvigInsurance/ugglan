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
    private let authentificationService = AuthentificationService()
    public override func effects(
        _ getState: @escaping () -> AuthenticationState,
        _ action: AuthenticationAction
    ) async {
        if case let .otpStateAction(action: .setCode(code)) = action {
            Task {
                let generator = await UIImpactFeedbackGenerator(style: .light)
                await generator.impactOccurred()
            }
            if code.count == 6 {
                send(.otpStateAction(action: .verifyCode))
                send(.otpStateAction(action: .setLoading(isLoading: true)))
            }
        } else if case .otpStateAction(action: .verifyCode) = action {
            let state = getState()
            do {
                let code = try await authentificationService.submit(otpState: state.otpState)
                send(.exchange(code: code))
            } catch let error {
                send(.otpStateAction(action: .setCodeError(message: error.localizedDescription)))
            }
        } else if case .otpStateAction(action: .setCodeError) = action {
            Task {
                let generator = await UINotificationFeedbackGenerator()
                await generator.notificationOccurred(.error)
            }
            send(.otpStateAction(action: .setLoading(isLoading: false)))
        } else if case .otpStateAction(action: .submitOtpData) = action {
            let state = getState()
            do {
                let data = try await authentificationService.start(with: state.otpState)
                send(.otpStateAction(action: .startSession(verifyUrl: data.verifyUrl, resendUrl: data.resendUrl)))
            } catch let error {
                send(.otpStateAction(action: .setLoading(isLoading: false)))
                send(.otpStateAction(action: .setOtpInputError(message: error.localizedDescription)))
            }
        } else if case .navigationAction(action: .authSuccess) = action {
            Task {
                let generator = await UINotificationFeedbackGenerator()
                await generator.notificationOccurred(.success)
            }
            send(.bankIdQrResultAction(action: .loggedIn))
        } else if case .otpStateAction(action: .resendCode) = action {
            let state = getState()
            do {
                try await authentificationService.resend(otp: state.otpState)
                send(.otpStateAction(action: .showResentToast))
            } catch _ {

            }
        } else if case .otpStateAction(action: .showResentToast) = action {
            Toasts.shared.displayToast(
                toast: .init(
                    symbol: .icon(hCoreUIAssets.refresh.image),
                    body: L10n.Login.Snackbar.codeResent
                )
            )
        } else if case let .exchange(code) = action {
            do {
                let successResult = try await authentificationService.exchange(code: code)
                ApolloClient.handleAuthTokenSuccessResult(result: successResult)
                send(.navigationAction(action: .authSuccess))
            } catch {

            }
        } else if case let .impersonate(code) = action {
            do {
                let successResult = try await authentificationService.exchange(code: code)
                ApolloClient.handleAuthTokenSuccessResult(result: successResult)
                send(.navigationAction(action: .impersonation))
            } catch {

            }
        } else if case .logout = action {
            do {
                try await authentificationService.logout()
                send(.logoutSuccess)
            } catch let error {
                send(.logoutFailure)
            }
        }
    }

    public override func reduce(_ state: AuthenticationState, _ action: AuthenticationAction) -> AuthenticationState {
        var newState = state

        switch action {
        case let .otpStateAction(action):
            switch action {
            case .reset:
                newState.otpState = .init()
            case let .setCode(code):
                if state.otpState.isLoading {
                    return newState
                }

                if code.count <= 6 {
                    newState.otpState.code = String(code.prefix(6))
                } else {
                    newState.otpState.code = String(code.suffix(1))
                }

                newState.otpState.codeErrorMessage = nil
            case let .setLoading(isLoading):
                newState.otpState.isLoading = isLoading
            case let .setCodeError(message):
                newState.otpState.codeErrorMessage = message
            case let .setEmail(email):
                newState.otpState.email = email
                newState.otpState.otpInputErrorMessage = nil
                newState.otpState.personalNumber = nil
            case let .setOtpInputError(message):
                newState.otpState.otpInputErrorMessage = message
            case let .setPersonalNumber(personalNumber):
                newState.otpState.personalNumber = personalNumber
                newState.otpState.otpInputErrorMessage = nil
                newState.otpState.email = nil
            case let .startSession(verifyUrl, resendUrl):
                newState.otpState.code = ""
                newState.otpState.verifyUrl = verifyUrl
                newState.otpState.resendUrl = resendUrl
                newState.otpState.isLoading = false
                newState.otpState.codeErrorMessage = nil
                newState.otpState.otpInputErrorMessage = nil
                newState.otpState.canResendAt = Date().addingTimeInterval(60)
                newState.otpState.isResending = false
            case .resendCode:
                newState.otpState.code = ""
                newState.otpState.codeErrorMessage = nil
                newState.otpState.isResending = true
            case .showResentToast:
                newState.otpState.isResending = false
            case .submitOtpData:
                newState.otpState.otpInputErrorMessage = nil
            default:
                break
            }
        default:
            break
        }

        return newState
    }

}

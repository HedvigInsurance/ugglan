import Foundation
import Testing
import hCore

@testable import AuthenticationCore

@MainActor
final class AuthenticationTests {
    @Test
    func submitSuccess() async throws {
        let submit = "submit"

        try await assertDeallocates(
            { MockData.createAuthenticationService(submitAuth: { _ in submit }) }
        ) { mockService in
            let respondedState = try await mockService.submitAuth(
                .init(
                    isLoading: false,
                    isResending: false,
                    resendUrl: nil,
                    verifyUrl: nil,
                    code: "code",
                    codeErrorMessage: nil,
                    otpInputErrorMessage: nil,
                    input: "input",
                    maskedEmail: nil,
                    canResendAt: nil
                )
            )
            #expect(respondedState == submit)
        }
    }

    @Test
    func startSuccess() async throws {
        let startData: (verifyUrl: URL, resendUrl: URL, maskedEmail: String?) = (
            verifyUrl: URL(string: "verifyURL")!,
            resendUrl: URL(string: "resendUrl")!,
            maskedEmail: "email@email.com"
        )

        try await assertDeallocates(
            { MockData.createAuthenticationService(startAuth: { _ in startData }) }
        ) { mockService in
            let respondedState = try await mockService.startAuth(
                .init(
                    isLoading: false,
                    isResending: false,
                    resendUrl: startData.resendUrl,
                    verifyUrl: startData.verifyUrl,
                    code: "code",
                    codeErrorMessage: nil,
                    otpInputErrorMessage: nil,
                    input: "input",
                    maskedEmail: startData.maskedEmail,
                    canResendAt: nil
                )
            )
            #expect(respondedState == startData)
        }
    }
}

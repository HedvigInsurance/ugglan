import XCTest
import hCore

@testable import Authentication

@MainActor
final class AuthenticationTests: XCTestCase {
    weak var sut: MockAuthenticationService?

    override func setUp() {
        super.setUp()
    }

    override func tearDown() async throws {
        Dependencies.shared.remove(for: AuthenticationClient.self)
        try await Task.sleep(nanoseconds: 100)

        XCTAssertNil(sut)
    }

    func testSubmitSuccess() async {
        let submit = "submit"

        let mockService = MockData.createAuthenticationService(
            submitAuth: { _ in
                submit
            }
        )
        sut = mockService

        let respondedState = try! await mockService.submitAuth(
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
        assert(respondedState == submit)
    }

    func testStartSuccess() async {
        let startData: (verifyUrl: URL, resendUrl: URL, maskedEmail: String?) = (
            verifyUrl: URL(string: "verifyURL")!,
            resendUrl: URL(string: "resendUrl")!,
            maskedEmail: "email@email.com"
        )

        let mockService = MockData.createAuthenticationService(
            startAuth: { _ in
                startData
            }
        )
        sut = mockService

        let respondedState = try! await mockService.startAuth(
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
        assert(respondedState == startData)
    }
}

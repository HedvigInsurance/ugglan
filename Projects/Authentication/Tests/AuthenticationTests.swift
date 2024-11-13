import XCTest
import hCore

@testable import Authentication

final class AuthenticationTests: XCTestCase {
    weak var sut: MockAuthenticationService?

    override func setUp() {
        super.setUp()
        sut = nil
    }

    override func tearDown() async throws {
        await Dependencies.shared.remove(for: AuthenticationClient.self)
        try await Task.sleep(nanoseconds: 100)

        XCTAssertNil(sut)
    }

    func testSubmitSuccess() async {
        let submit = "submit"

        let mockService = MockData.createAuthenticationService(
            submitAuth: { state in
                submit
            }
        )
        self.sut = mockService

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
            startAuth: { state in
                startData
            }
        )
        self.sut = mockService

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

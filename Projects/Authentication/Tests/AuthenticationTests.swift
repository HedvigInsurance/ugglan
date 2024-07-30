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
        Dependencies.shared.remove(for: AuthenticationClient.self)
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
}

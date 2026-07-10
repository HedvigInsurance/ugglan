import Apollo
@preconcurrency import XCTest
import hGraphQL

@testable import SubmitClaimChat
@testable import Ugglan

@MainActor
final class ClaimIntentInformationMappingTests: XCTestCase {
    func testInformationFragmentMappingSuccess() async throws {
        let fragment = try await OctopusGraphQL.ClaimIntentStepContentFragment(
            data: Self.informationFragmentJSON(severity: "CRITICAL")
        )

        let content = try ClaimIntentStepContent(fragment: fragment)

        guard case let .information(model) = content else {
            XCTFail("Expected information content")
            return
        }
        XCTAssertEqual(model.notice, "Seek emergency accommodation.")
        XCTAssertEqual(model.severity, .critical)
        XCTAssertEqual(model.buttonTitle, "I understand")
    }

    func testUnknownInformationSeverityDegradesToInfoSuccess() async throws {
        let fragment = try await OctopusGraphQL.ClaimIntentStepContentFragment(
            data: Self.informationFragmentJSON(severity: "SOMETHING_UNEXPECTED")
        )

        let content = try ClaimIntentStepContent(fragment: fragment)

        guard case let .information(model) = content else {
            XCTFail("Expected information content")
            return
        }
        XCTAssertEqual(model.severity, .info)
    }

    private nonisolated static func informationFragmentJSON(severity: String) -> [String: Any] {
        [
            "__typename": "ClaimIntentStepContentInformation",
            "notice": "Seek emergency accommodation.",
            "severity": severity,
            "buttonTitle": "I understand",
        ]
    }
}

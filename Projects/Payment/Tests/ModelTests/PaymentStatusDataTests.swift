@preconcurrency import XCTest

@testable import Payment

@MainActor
final class PaymentStatusDataTests: XCTestCase {
    private func makeStatusData(memberPhoneNumber: String?) -> PaymentStatusData {
        .init(
            status: .needsSetup,
            chargingDay: 27,
            defaultPayinMethod: nil,
            payinMethods: [],
            defaultPayoutMethod: nil,
            payoutMethods: [],
            availableMethods: [.init(provider: .swish, supportsPayin: true, supportsPayout: true)],
            missingConnection: .payin,
            layout: .other,
            memberPhoneNumber: memberPhoneNumber
        )
    }

    func testMemberPhoneNumberDefaultsToNil() {
        let statusData: PaymentStatusData = .init(
            status: .needsSetup,
            chargingDay: nil,
            defaultPayinMethod: nil,
            payinMethods: [],
            defaultPayoutMethod: nil,
            payoutMethods: [],
            availableMethods: [],
            missingConnection: nil,
            layout: .other
        )

        XCTAssertNil(statusData.memberPhoneNumber)
    }

    func testMemberPhoneNumberCodingRoundTripSuccess() throws {
        let statusData = makeStatusData(memberPhoneNumber: "0735328847")

        let encoded = try JSONEncoder().encode(statusData)
        let decoded = try JSONDecoder().decode(PaymentStatusData.self, from: encoded)

        XCTAssertEqual(decoded.memberPhoneNumber, "0735328847")
        XCTAssertEqual(decoded, statusData)
    }

    func testDecodingSnapshotWithoutMemberPhoneNumberSuccess() throws {
        let encoded = try JSONEncoder().encode(makeStatusData(memberPhoneNumber: "0735328847"))
        var json = try XCTUnwrap(
            JSONSerialization.jsonObject(with: encoded) as? [String: Any],
            "PaymentStatusData is expected to encode as a JSON object"
        )
        json.removeValue(forKey: "memberPhoneNumber")
        let legacyEncoded = try JSONSerialization.data(withJSONObject: json)

        let decoded = try JSONDecoder().decode(PaymentStatusData.self, from: legacyEncoded)

        XCTAssertNil(decoded.memberPhoneNumber)
        XCTAssertEqual(decoded, makeStatusData(memberPhoneNumber: nil))
    }
}

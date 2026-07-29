import XCTest
import hCore

@testable import Ugglan

@MainActor
final class PendingAppIntentServiceTests: XCTestCase {
    private var now: Date!

    override func setUp() {
        super.setUp()
        now = Date(timeIntervalSince1970: 1_000_000)
    }

    private func makeService() -> PendingAppIntentService {
        PendingAppIntentService(clock: { [weak self] in self?.now ?? Date() })
    }

    func testStoreThenConsumeReturnsAction() {
        let service = makeService()
        service.store(.fileNewClaim)
        XCTAssertEqual(service.consume(), .fileNewClaim)
    }

    func testConsumeReturnsNilAfterPendingTTLExpired() {
        let service = makeService()
        service.store(.fileNewClaim)
        now = now.addingTimeInterval(PendingAppIntentService.pendingTTL + 1)
        XCTAssertNil(service.consume())
    }

    func testConsumeReturnsNilWhenNothingStored() {
        let service = makeService()
        XCTAssertNil(service.consume())
    }

    func testSecondConsumeReturnsNil() {
        let service = makeService()
        service.store(.fileNewClaim)
        _ = service.consume()
        XCTAssertNil(service.consume())
    }

    func testRecoverInFlightMovesActionBackToPending() {
        let service = makeService()
        service.store(.fileNewClaim)
        XCTAssertEqual(service.consume(), .fileNewClaim)

        service.recoverInFlight()

        XCTAssertEqual(service.consume(), .fileNewClaim)
    }

    func testRecoverInFlightIsNoOpWhenNothingInFlight() {
        let service = makeService()
        service.recoverInFlight()
        XCTAssertNil(service.consume())
    }

    func testRecoverInFlightResetsTTL() {
        let service = makeService()
        service.store(.fileNewClaim)
        XCTAssertEqual(service.consume(), .fileNewClaim)

        now = now.addingTimeInterval(PendingAppIntentService.pendingTTL - 1)
        service.recoverInFlight()
        now = now.addingTimeInterval(PendingAppIntentService.pendingTTL - 1)
        XCTAssertEqual(service.consume(), .fileNewClaim)
    }

    func testInFlightAutoClearsAfterWindow() {
        let service = makeService()
        service.store(.fileNewClaim)
        XCTAssertEqual(service.consume(), .fileNewClaim)

        now = now.addingTimeInterval(PendingAppIntentService.inFlightAutoClearAfter + 1)
        _ = service.consume()

        service.recoverInFlight()
        XCTAssertNil(service.consume())
    }
}

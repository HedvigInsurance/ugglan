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
}

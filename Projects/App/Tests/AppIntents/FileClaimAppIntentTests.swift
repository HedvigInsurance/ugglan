import Combine
import XCTest
import hCore

@testable import Ugglan

@MainActor
final class FileClaimAppIntentTests: XCTestCase {
    func testPerformStoresFileNewClaim() async throws {
        let stub = StubPendingAppIntentService()
        Dependencies.shared.add(module: Module { () -> PendingAppIntentServiceProtocol in stub })

        let intent = FileClaimAppIntent()
        _ = try await intent.perform()

        XCTAssertEqual(stub.stored, [.fileNewClaim])
    }
}

@MainActor
private final class StubPendingAppIntentService: PendingAppIntentServiceProtocol {
    var stored: [PendingAppIntentAction] = []
    var storedPublisher: AnyPublisher<Void, Never> { Empty().eraseToAnyPublisher() }
    func store(_ action: PendingAppIntentAction) { stored.append(action) }
    func consume() -> PendingAppIntentAction? { nil }
    func recoverInFlight() {}
}

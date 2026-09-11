import Foundation
import XCTest
import hCore
import hCoreUI

@testable import TerminateContracts

@MainActor
final class TerminationFlowNavigationViewModelRetainTests: XCTestCase {
    weak var sut: MockTerminateContractsClient?

    override func setUp() async throws {
        try await super.setUp()
        // TerminateContractsService resolves the client lazily through @Inject. The stub answers
        // immediately and never throws, so no request or retry can outlive the drop points below.
        let mockClient = MockTerminateContractsClient()
        sut = mockClient
        Dependencies.shared.add(module: Module { () -> TerminateContractsClient in mockClient })
    }

    override func tearDown() async throws {
        Dependencies.shared.remove(for: TerminateContractsClient.self)
        try await Task.sleep(for: .seconds(0.0000001))
        XCTAssertNil(sut)
        try await super.tearDown()
    }

    func testViewModelIsReleasedWhileItsRouterLives() {
        var vm: TerminationFlowNavigationViewModel? = .init(
            config: MockTerminationData.testConfig,
            surveyData: MockTerminationData.terminateSurveyData,
            terminateInsuranceViewModel: nil
        )
        weak let weakVm = vm
        // The router is handed to hNavigationStack and outlives the view model in production. Its
        // $routeTypes subject keeps the stored sink subscribed, so holding the router past the drop
        // is what makes a strong capture inside that sink observable.
        let router = vm!.router

        settleRouterPathSync()

        router.push(TerminationFlowFinalRouterActions.success)
        XCTAssertEqual(router.routeTypes.count, 1, "push must record the pushed route type")

        XCTAssertTrue(pumpUntilFinalRouteProgressIsNil(vm!), "the $routeTypes sink never saw the pushed route")

        vm = nil

        XCTAssertNil(weakVm, "the $routeTypes sink stored on the view model must not capture it strongly")
        _ = router
    }

    func testMultiConfigViewModelIsReleasedWhileItsRouterLives() {
        var vm: TerminationFlowNavigationViewModel? = .init(
            configs: [MockTerminationData.testConfig],
            terminateInsuranceViewModel: nil
        )
        weak let weakVm = vm
        // The select-insurance init installs its own byte-identical $routeTypes sink, so it needs its
        // own guard: a strong capture there leaks every multi-contract flow the user opens.
        let router = vm!.router

        settleRouterPathSync()

        router.push(TerminationFlowFinalRouterActions.success)
        XCTAssertEqual(router.routeTypes.count, 1, "push must record the pushed route type")

        XCTAssertTrue(pumpUntilFinalRouteProgressIsNil(vm!), "the $routeTypes sink never saw the pushed route")

        vm = nil

        XCTAssertNil(weakVm, "the $routeTypes sink stored on the view model must not capture it strongly")
        _ = router
    }

    func testNotificationTaskDoesNotRetainViewModel() {
        var vm: TerminationFlowNavigationViewModel? = .init(
            config: MockTerminationData.testConfig,
            surveyData: MockTerminationData.terminateSurveyData,
            terminateInsuranceViewModel: nil
        )
        weak let weakVm = vm

        // Drain the deliveries the two initializer subscriptions queued, so nothing but the task is
        // still pending at the drop. Pumping after fetchNotification would instead let the task body
        // start and hold a strong self across its await, which is exactly what must not be measured.
        settleRouterPathSync()

        vm!.fetchNotification(for: Date())
        // The task handle is the storage under test, so it is held past the drop: while the task has
        // not started, only the closure it carries can keep the view model alive.
        let notificationTask = vm!.fetchNotificationTask
        XCTAssertNotNil(notificationTask, "fetchNotification must store its task on the view model")

        vm = nil

        XCTAssertNil(weakVm, "the notification task must not capture the view model strongly")
        // This test never suspends, so the task body has not run yet. Cancelling both uses the handle
        // (keeping it alive to this point) and makes sure a strong-capture regression cannot resolve
        // the client after tearDown removed it, which would fatalError instead of failing cleanly.
        notificationTask?.cancel()
    }

    /// Lets the deliveries queued by a freshly built view model land before the test pushes anything.
    /// NavigationRouter.init subscribes to its own `$path` with `receive(on: RunLoop.main)`, so the
    /// initial empty path is already queued when the view model is constructed. It has to arrive
    /// while `routeTypes` is still empty: arriving after a push, it sees `newPath.count (0) <
    /// routeTypes.count (1)` and truncates `routeTypes` back to empty. `updateProgress()` reads that
    /// live array, so without this turn it never takes the final-route branch and every test's
    /// precondition would be unreachable.
    private func settleRouterPathSync() {
        let settled = expectation(description: "router path sync settled")
        RunLoop.main.perform { settled.fulfill() }
        wait(for: [settled], timeout: 1)
    }

    /// Pumps bounded run-loop turns until the stored sink has demonstrably run, rather than sleeping
    /// blind: `progress` starts at 0 and only `updateProgress()` can turn it nil (it saw a final
    /// route), so a nil progress proves the closure under test really executed.
    private func pumpUntilFinalRouteProgressIsNil(_ vm: TerminationFlowNavigationViewModel) -> Bool {
        for turn in 1...10 {
            if vm.progress == nil { return true }
            let pumped = expectation(description: "run loop turn \(turn)")
            RunLoop.main.perform { pumped.fulfill() }
            wait(for: [pumped], timeout: 1)
        }
        return vm.progress == nil
    }
}

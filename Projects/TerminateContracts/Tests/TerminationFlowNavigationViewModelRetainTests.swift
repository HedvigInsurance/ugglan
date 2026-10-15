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

    func testViewModelIsReleasedWhileItsRouterLives() async {
        var vm: TerminationFlowNavigationViewModel? = .init(
            config: MockTerminationData.testConfig,
            surveyData: MockTerminationData.terminateSurveyData,
            terminateInsuranceViewModel: nil
        )
        weak let weakVm = vm
        // The router is handed to hNavigationStack and outlives the view model in production. Its
        // observation registrar keeps the armed onChange closure, so holding the router past the drop
        // is what makes a strong capture inside that closure observable.
        let router = vm!.router

        router.push(TerminationFlowFinalRouterActions.success)
        XCTAssertEqual(router.routeTypes.count, 1, "push must record the pushed route type")

        let sawFinalRoute = await yieldUntilFinalRouteProgressIsNil(vm!)
        XCTAssertTrue(sawFinalRoute, "the routeTypes observation never saw the pushed route")

        vm = nil

        XCTAssertNil(weakVm, "the routeTypes observation must not capture the view model strongly")
        _ = router
    }

    func testMultiConfigViewModelIsReleasedWhileItsRouterLives() async {
        var vm: TerminationFlowNavigationViewModel? = .init(
            configs: [MockTerminationData.testConfig],
            terminateInsuranceViewModel: nil
        )
        weak let weakVm = vm
        // The select-insurance init arms its own routeTypes observation, so it needs its
        // own guard: a strong capture there leaks every multi-contract flow the user opens.
        let router = vm!.router

        router.push(TerminationFlowFinalRouterActions.success)
        XCTAssertEqual(router.routeTypes.count, 1, "push must record the pushed route type")

        let sawFinalRoute = await yieldUntilFinalRouteProgressIsNil(vm!)
        XCTAssertTrue(sawFinalRoute, "the routeTypes observation never saw the pushed route")

        vm = nil

        XCTAssertNil(weakVm, "the routeTypes observation must not capture the view model strongly")
        _ = router
    }

    func testNotificationTaskDoesNotRetainViewModel() {
        var vm: TerminationFlowNavigationViewModel? = .init(
            config: MockTerminationData.testConfig,
            surveyData: MockTerminationData.terminateSurveyData,
            terminateInsuranceViewModel: nil
        )
        weak let weakVm = vm

        // Kept synchronous on purpose: suspending after fetchNotification would let the task body
        // start and hold a strong self across its await, which is exactly what must not be measured.
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

    /// Suspends in bounded steps until the routeTypes observation has demonstrably run, rather than
    /// sleeping blind: `progress` starts at 0 and only `updateProgress()` can turn it nil (it saw a
    /// final route), so a nil progress proves the closure under test really executed. The onChange
    /// hops to the main actor through a Task, which cannot start while a synchronous test body holds
    /// the main actor, so this has to await rather than pump the run loop with `wait(for:)`.
    private func yieldUntilFinalRouteProgressIsNil(_ vm: TerminationFlowNavigationViewModel) async -> Bool {
        for _ in 1...10 {
            if vm.progress == nil { return true }
            try? await Task.sleep(for: .seconds(0.01))
        }
        return vm.progress == nil
    }
}

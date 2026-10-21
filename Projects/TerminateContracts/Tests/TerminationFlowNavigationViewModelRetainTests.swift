import Foundation
import Testing
import hCore
import hCoreUI

@testable import TerminateContracts

extension TerminateContractsDependencySuite {
    @MainActor
    final class TerminationFlowNavigationViewModelRetainTests {
        private weak var sut: MockTerminateContractsClient?

        init() {
            // The stub answers immediately and never throws, so no request outlives the drop points below.
            let mockClient = MockTerminateContractsClient()
            sut = mockClient
            Dependencies.shared.add(module: Module { () -> TerminateContractsClient in mockClient })
        }

        @Test
        func viewModelIsReleasedWhileItsRouterLives() async {
            var vm: TerminationFlowNavigationViewModel? = .init(
                config: MockTerminationData.testConfig,
                surveyData: MockTerminationData.terminateSurveyData,
                terminateInsuranceViewModel: nil
            )
            weak let weakVm = vm
            // Held past the drop, as in production, so a strong capture in its onChange closure shows.
            let router = vm!.router

            router.push(TerminationFlowFinalRouterActions.success)
            #expect(router.routeTypes.count == 1, "push must record the pushed route type")

            let sawFinalRoute = await yieldUntilFinalRouteProgressIsNil(vm!)
            #expect(sawFinalRoute, "the routeTypes observation never saw the pushed route")

            vm = nil

            #expect(weakVm == nil, "the routeTypes observation must not capture the view model strongly")
            _ = router

            await expectClientReleased()
        }

        @Test
        func multiConfigViewModelIsReleasedWhileItsRouterLives() async {
            var vm: TerminationFlowNavigationViewModel? = .init(
                configs: [MockTerminationData.testConfig],
                terminateInsuranceViewModel: nil
            )
            weak let weakVm = vm
            let router = vm!.router

            router.push(TerminationFlowFinalRouterActions.success)
            #expect(router.routeTypes.count == 1, "push must record the pushed route type")

            let sawFinalRoute = await yieldUntilFinalRouteProgressIsNil(vm!)
            #expect(sawFinalRoute, "the routeTypes observation never saw the pushed route")

            vm = nil

            #expect(weakVm == nil, "the routeTypes observation must not capture the view model strongly")
            _ = router

            await expectClientReleased()
        }

        @Test
        func notificationTaskDoesNotRetainViewModel() async {
            var vm: TerminationFlowNavigationViewModel? = .init(
                config: MockTerminationData.testConfig,
                surveyData: MockTerminationData.terminateSurveyData,
                terminateInsuranceViewModel: nil
            )
            weak let weakVm = vm

            // No await until the drop is measured, or the task body could hold a strong self across it.
            vm!.fetchNotification(for: Date())
            // Held past the drop: before the task starts, only its closure can keep the view model alive.
            let notificationTask = vm!.fetchNotificationTask
            #expect(notificationTask != nil, "fetchNotification must store its task on the view model")

            vm = nil

            #expect(weakVm == nil, "the notification task must not capture the view model strongly")
            // Cancel so a strong-capture regression cannot resolve the client after module removal.
            notificationTask?.cancel()

            await expectClientReleased()
        }

        // Not deinit: this has to suspend before it reads sut.
        private func expectClientReleased() async {
            Dependencies.shared.remove(for: TerminateContractsClient.self)
            try? await Task.sleep(for: .seconds(0.0000001))
            #expect(sut == nil, "the mock client must not outlive its dependency registration")
        }

        // Awaits (not run-loop pumping) until progress turns nil, proving the routeTypes observation ran.
        private func yieldUntilFinalRouteProgressIsNil(_ vm: TerminationFlowNavigationViewModel) async -> Bool {
            for _ in 1...10 {
                if vm.progress == nil { return true }
                try? await Task.sleep(for: .seconds(0.01))
            }
            return vm.progress == nil
        }
    }
}

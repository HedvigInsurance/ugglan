import Testing
import hCore

@testable import TerminateContracts

extension TerminateContractsDependencySuite {
    @MainActor
    final class TerminationDateLandingScreenViewModelTests {
        private weak var sut: MockTerminateContractsClient?

        init() {
            let mockClient = MockTerminateContractsClient()
            mockClient.notificationToReturn = .init(message: "Test notification", type: .info)
            sut = mockClient
            Dependencies.shared.add(module: Module { () -> TerminateContractsClient in mockClient })
        }

        @Test
        func isDeletionWithDeleteAction() async {
            do {
                let navVM = TerminationFlowNavigationViewModel(
                    configs: [MockTerminationData.testConfig],
                    terminateInsuranceViewModel: nil
                )
                navVM.surveyData = MockTerminationData.deleteSurveyData
                #expect(navVM.isDeletion)
            }

            await expectClientReleased()
        }

        @Test
        func isDeletionWithTerminateAction() async {
            do {
                let navVM = TerminationFlowNavigationViewModel(
                    configs: [MockTerminationData.testConfig],
                    terminateInsuranceViewModel: nil
                )
                navVM.surveyData = MockTerminationData.terminateSurveyData
                #expect(!navVM.isDeletion)
            }

            await expectClientReleased()
        }

        @Test
        func extraCoverageFromAction() async {
            do {
                let navVM = TerminationFlowNavigationViewModel(
                    configs: [MockTerminationData.testConfig],
                    terminateInsuranceViewModel: nil
                )
                navVM.surveyData = MockTerminationData.terminateSurveyData
                #expect(navVM.extraCoverage.count == 1)
                #expect(navVM.extraCoverage.first?.displayName == "Travel plus")
            }

            await expectClientReleased()
        }

        // Not deinit: this has to suspend before it reads sut.
        private func expectClientReleased() async {
            Dependencies.shared.remove(for: TerminateContractsClient.self)
            try? await Task.sleep(for: .seconds(0.0000001))
            #expect(sut == nil, "the mock client must not outlive its dependency registration")
        }
    }
}

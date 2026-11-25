import Foundation
import TerminateContractsCore
import TestDependencies
import Testing
import hCore

@testable import TerminateContractsUI

extension TerminateContractsDependencySuite {
    @MainActor
    final class TerminationWithdrawalFlowTests {
        private weak var sut: MockTerminateContractsClient?
        private weak var vm: TerminationFlowNavigationViewModel?

        // MARK: - Withdrawal-choice init

        @Test
        func withdrawalChoiceInitStartsAtWithdrawalChoice() async {
            do {
                registerMockClient()
                let navVm = TerminationFlowNavigationViewModel(
                    withdrawalChoiceFor: MockTerminationData.withdrawalConfig,
                    terminateInsuranceViewModel: nil
                )
                vm = navVm

                #expect(navVm.initialStep == .router(action: .withdrawalChoice))
                #expect(navVm.config == MockTerminationData.withdrawalConfig)
                #expect(!navVm.hasSelectInsuranceStep)
                #expect(navVm.surveyData == nil)
                #expect(!navVm.isWithdrawal)
                #expect(navVm.router.routeTypes.isEmpty)
            }

            await expectReleased()
        }

        // MARK: - applyWithdrawal

        @Test
        func applyWithdrawalWithFixedDatePreselectsDateAndFetchesNotification() async {
            do {
                let mockClient = registerMockClient()
                mockClient.notificationToReturn = .init(message: "Withdrawn on date", type: .info)
                let navVm = makeWithdrawalChoiceViewModel()
                navVm.selectedOptionId = "opt1"
                navVm.selectedComment = "A comment"

                navVm.applyWithdrawal(MockTerminationData.fixedDateWithdrawal)

                #expect(navVm.isWithdrawal)
                #expect(navVm.withdrawal == MockTerminationData.fixedDateWithdrawal)
                #expect(navVm.surveyData == nil)
                #expect(navVm.action == MockTerminationData.fixedDateWithdrawal.action)
                #expect(navVm.selectedOptionId == nil)
                #expect(navVm.selectedComment == nil)
                #expect(navVm.selectedDate == "2026-11-20".localDateToDate)
                #expect(navVm.selectedDate != nil)
                #expect(!navVm.isDeletion)
                await navVm.fetchNotificationTask?.value
                #expect(navVm.notification == .init(message: "Withdrawn on date", type: .info))
                #expect(mockClient.events == [.getNotification(contractId: "contract-123")])
            }

            await expectReleased()
        }

        @Test
        func applyWithdrawalWithDateRangeClearsSelectedDate() async {
            do {
                registerMockClient()
                let navVm = makeWithdrawalChoiceViewModel()
                navVm.selectedDate = Date()

                navVm.applyWithdrawal(MockTerminationData.dateRangeWithdrawal)

                #expect(navVm.isWithdrawal)
                #expect(navVm.action == MockTerminationData.dateRangeWithdrawal.action)
                #expect(navVm.selectedDate == nil)
                #expect(navVm.terminationDateLimits?.min == "2026-11-24".localDateToDate)
                #expect(navVm.terminationDateLimits?.max == "2026-12-01".localDateToDate)
            }

            await expectReleased()
        }

        @Test
        func applyWithdrawalDeletionFetchesNotification() async {
            do {
                let mockClient = registerMockClient()
                mockClient.notificationToReturn = .init(message: "Deleted today", type: .info)
                let navVm = makeWithdrawalChoiceViewModel()
                navVm.selectedOptionId = "opt1"
                navVm.selectedDate = Date()

                navVm.applyWithdrawal(MockTerminationData.deletionWithdrawal)

                #expect(navVm.isWithdrawal)
                #expect(navVm.isDeletion)
                #expect(navVm.selectedOptionId == nil)
                #expect(navVm.selectedDate == nil)
                #expect(navVm.action == MockTerminationData.deletionWithdrawal.action)
                await navVm.fetchNotificationTask?.value
                #expect(navVm.notification == .init(message: "Deleted today", type: .info))
                #expect(mockClient.events == [.getNotification(contractId: "contract-123")])
            }

            await expectReleased()
        }

        // MARK: - fetchSurvey / startWithdrawal / startTermination

        @Test
        func fetchSurveyWithWithdrawalSupportPushesWithdrawalChoice() async {
            do {
                let mockClient = registerMockClient()
                let navVm = TerminationFlowNavigationViewModel(
                    configs: [MockTerminationData.withdrawalConfig, MockTerminationData.testConfig],
                    terminateInsuranceViewModel: nil
                )
                vm = navVm

                await navVm.fetchSurvey(for: MockTerminationData.withdrawalConfig)

                #expect(navVm.config == MockTerminationData.withdrawalConfig)
                #expect(mockClient.events.isEmpty, "the survey must not be fetched before the member chooses")
                #expect(navVm.surveyData == nil)
                #expect(navVm.router.routeTypes.count == 1)
                #expect(navVm.router.routeTypes.last == TerminationFlowRouterActions.self)
            }

            await expectReleased()
        }

        @Test
        func fetchSurveyWithoutWithdrawalSupportFetchesSurvey() async {
            do {
                let mockClient = registerMockClient()
                let navVm = TerminationFlowNavigationViewModel(
                    configs: [MockTerminationData.withdrawalConfig, MockTerminationData.testConfig],
                    terminateInsuranceViewModel: nil
                )
                vm = navVm

                await navVm.fetchSurvey(for: MockTerminationData.testConfig)

                #expect(mockClient.events == [.getTerminationSurvey(contractId: "contract-123")])
                #expect(navVm.surveyData == MockTerminationData.terminateSurveyData)
                #expect(!navVm.isWithdrawal)
                #expect(navVm.router.routeTypes.count == 1)
                #expect(navVm.router.routeTypes.last == TerminationFlowRouterActions.self)
            }

            await expectReleased()
        }

        @Test
        func startWithdrawalSuccess() async {
            do {
                let mockClient = registerMockClient()
                mockClient.withdrawalDataToReturn = MockTerminationData.fixedDateWithdrawal
                let navVm = makeWithdrawalChoiceViewModel()

                await navVm.startWithdrawal()
                await navVm.fetchNotificationTask?.value

                #expect(
                    mockClient.events == [
                        .getContractWithdrawal(contractId: "contract-123"),
                        .getNotification(contractId: "contract-123"),
                    ]
                )
                #expect(navVm.withdrawal == MockTerminationData.fixedDateWithdrawal)
                #expect(navVm.selectedDate == "2026-11-20".localDateToDate)
                #expect(!navVm.fetchingSurvey)
                #expect(navVm.router.routeTypes.last == TerminationFlowRouterActions.self)
            }

            await expectReleased()
        }

        @Test
        func startWithdrawalFailure() async {
            do {
                let mockClient = registerMockClient()
                mockClient.errorToThrow = NSError(domain: "test", code: 1)
                let navVm = makeWithdrawalChoiceViewModel()

                await navVm.startWithdrawal()

                #expect(mockClient.events == [.getContractWithdrawal(contractId: "contract-123")])
                #expect(!navVm.isWithdrawal)
                #expect(!navVm.fetchingSurvey)
                #expect(navVm.router.routeTypes.last == TerminationFlowFinalRouterActions.self)
            }

            await expectReleased()
        }

        @Test
        func startTerminationAfterWithdrawalClearsWithdrawal() async {
            do {
                let mockClient = registerMockClient()
                mockClient.notificationToReturn = .init(message: "Withdrawn on date", type: .info)
                let navVm = makeWithdrawalChoiceViewModel()
                navVm.applyWithdrawal(MockTerminationData.fixedDateWithdrawal)
                await navVm.fetchNotificationTask?.value
                #expect(navVm.notification != nil)

                await navVm.startTermination()

                #expect(
                    mockClient.events == [
                        .getNotification(contractId: "contract-123"),
                        .getTerminationSurvey(contractId: "contract-123"),
                    ]
                )
                #expect(!navVm.isWithdrawal)
                #expect(navVm.surveyData == MockTerminationData.terminateSurveyData)
                #expect(navVm.action == MockTerminationData.terminateSurveyData.action)
                #expect(navVm.selectedDate == nil)
                #expect(navVm.notification == nil, "the withdrawal's notification must not reach the cancellation")
                #expect(navVm.router.routeTypes.last == TerminationFlowRouterActions.self)
            }

            await expectReleased()
        }

        @Test
        func applyWithdrawalAfterSurveyUsesWithdrawalAction() async {
            do {
                registerMockClient()
                let navVm = makeWithdrawalChoiceViewModel()
                await navVm.startTermination()
                navVm.selectedOptionId = "opt1"
                navVm.selectedComment = "A comment"

                navVm.applyWithdrawal(MockTerminationData.deletionWithdrawal)
                await navVm.fetchNotificationTask?.value

                #expect(
                    navVm.surveyData == MockTerminationData.terminateSurveyData,
                    "the survey is kept for going back"
                )
                #expect(navVm.action == MockTerminationData.deletionWithdrawal.action)
                #expect(navVm.isDeletion)
                #expect(navVm.selectedOptionId == nil)
                #expect(navVm.selectedComment == nil)
            }

            await expectReleased()
        }

        // MARK: - successTitle

        @Test
        func successTitleForWithdrawalSaysWithdrawn() async {
            do {
                registerMockClient()
                let navVm = makeWithdrawalChoiceViewModel()
                navVm.applyWithdrawal(MockTerminationData.dateRangeWithdrawal)

                #expect(navVm.successTitle == L10n.terminationFlowWithdrawalSuccessTitle)
            }

            await expectReleased()
        }

        @Test
        func successTitleWithoutWithdrawalSaysCancelled() async {
            do {
                registerMockClient()
                let navVm = makeWithdrawalChoiceViewModel()

                #expect(navVm.successTitle == L10n.terminationFlowSuccessTitle)
            }

            await expectReleased()
        }

        // MARK: - successBody

        @Test
        func successBodyForWithdrawalEndingTodaySaysToday() async {
            do {
                registerMockClient()
                let navVm = makeWithdrawalChoiceViewModel()
                let today = Date().localDateString
                navVm.applyWithdrawal(
                    .init(
                        statusText: "",
                        action: .terminateWithDate(minDate: today, maxDate: today, extraCoverage: []),
                        email: "member@hedvig.com"
                    )
                )
                await navVm.fetchNotificationTask?.value

                let date = navVm.selectedDate?.displayDateDDMMMYYYYFormat ?? ""
                #expect(navVm.successBody == L10n.terminationFlowConfirmationSubtitleToday(date))
            }

            await expectReleased()
        }

        @Test
        func successBodyForWithdrawalWithFixedDateShowsDate() async {
            do {
                registerMockClient()
                let navVm = makeWithdrawalChoiceViewModel()
                navVm.applyWithdrawal(MockTerminationData.fixedDateWithdrawal)
                await navVm.fetchNotificationTask?.value

                let date = "2026-11-20".localDateToDate?.displayDateDDMMMYYYYFormat ?? ""
                #expect(navVm.successBody == L10n.terminationFlowSuccessSubtitleWithDate(date))
            }

            await expectReleased()
        }

        @Test
        func successBodyForWithdrawalWithoutDateDoesNotShowEmptyDate() async {
            do {
                registerMockClient()
                let navVm = makeWithdrawalChoiceViewModel()
                navVm.applyWithdrawal(MockTerminationData.dateRangeWithdrawal)

                #expect(navVm.successBody == L10n.terminationFlowConfirmation)
            }

            await expectReleased()
        }

        @Test
        func successBodyForWithdrawalDeletionSaysNotCharged() async {
            do {
                registerMockClient()
                let navVm = makeWithdrawalChoiceViewModel()
                navVm.applyWithdrawal(MockTerminationData.deletionWithdrawal)
                await navVm.fetchNotificationTask?.value

                #expect(navVm.successBody == L10n.terminateContractTerminationComplete)
            }

            await expectReleased()
        }

        // MARK: - submitTermination

        @Test
        func submitTerminationWhenWithdrawingCallsWithdrawContract() async {
            do {
                let mockClient = registerMockClient()
                let navVm = makeWithdrawalChoiceViewModel()
                navVm.applyWithdrawal(MockTerminationData.fixedDateWithdrawal)
                await navVm.fetchNotificationTask?.value

                navVm.submitTermination()

                // withdrawContract holds for the service's 3 s minimum duration.
                await waitUntil(description: "the withdrawal result is pushed", timeout: 6) {
                    navVm.router.routeTypes.last == TerminationFlowFinalRouterActions.self
                }
                #expect(
                    mockClient.events == [
                        .getNotification(contractId: "contract-123"),
                        .withdrawContract(contractId: "contract-123"),
                    ]
                )
                #expect(navVm.confirmTerminationState == .success)
                #expect(!navVm.isProcessingPresented)
            }

            await expectReleased()
        }

        @Test
        func submitTerminationWhenWithdrawingDeletionCallsWithdrawContract() async {
            do {
                let mockClient = registerMockClient()
                let navVm = makeWithdrawalChoiceViewModel()
                navVm.applyWithdrawal(MockTerminationData.deletionWithdrawal)
                await navVm.fetchNotificationTask?.value

                navVm.submitTermination()

                await waitUntil(description: "the withdrawal result is pushed", timeout: 6) {
                    navVm.router.routeTypes.last == TerminationFlowFinalRouterActions.self
                }
                #expect(
                    mockClient.events == [
                        .getNotification(contractId: "contract-123"),
                        .withdrawContract(contractId: "contract-123"),
                    ]
                )
            }

            await expectReleased()
        }

        @Test
        func submitTerminationWithoutOptionAndWithdrawalDoesNothing() async {
            do {
                let mockClient = registerMockClient()
                let navVm = TerminationFlowNavigationViewModel(
                    config: MockTerminationData.testConfig,
                    surveyData: MockTerminationData.terminateSurveyData,
                    terminateInsuranceViewModel: nil
                )
                vm = navVm

                navVm.submitTermination()
                await delay(0.05)

                #expect(mockClient.events.isEmpty)
                #expect(!navVm.isProcessingPresented)
                #expect(navVm.router.routeTypes.isEmpty)
            }

            await expectReleased()
        }

        // MARK: - Helpers

        @discardableResult
        private func registerMockClient() -> MockTerminateContractsClient {
            let mockClient = MockTerminateContractsClient()
            sut = mockClient
            Dependencies.shared.add(module: Module { () -> TerminateContractsClient in mockClient })
            // applyWithdrawal and the date limits parse "yyyy-MM-dd" strings through DateService.
            Dependencies.shared.add(module: Module { () -> DateService in DateService() })
            return mockClient
        }

        private func makeWithdrawalChoiceViewModel() -> TerminationFlowNavigationViewModel {
            let navVm = TerminationFlowNavigationViewModel(
                withdrawalChoiceFor: MockTerminationData.withdrawalConfig,
                terminateInsuranceViewModel: nil
            )
            vm = navVm
            return navVm
        }

        // Not deinit: this has to suspend before it reads sut.
        private func expectReleased() async {
            // A submit/notification Task may still hold the view model; its @Inject needs the client registered.
            await waitUntil(description: "the navigation view model is released") { self.vm == nil }
            Dependencies.shared.remove(for: TerminateContractsClient.self)
            Dependencies.shared.remove(for: DateService.self)
            await delay(0.00001)
            #expect(sut == nil, "the mock client must not outlive the test that created it")
        }
    }

    @MainActor
    final class TerminateInsuranceViewModelWithdrawalTests {
        private weak var sut: MockTerminateContractsClient?
        private weak var vm: TerminateInsuranceViewModel?

        @Test
        func startWithSingleWithdrawalConfigOpensWithdrawalChoice() async {
            await recordingErrors {
                let mockClient = registerMockClient()
                let terminateVm = TerminateInsuranceViewModel()
                vm = terminateVm

                try await terminateVm.start(with: [MockTerminationData.withdrawalConfig])

                let flowVm = try #require(terminateVm.flowNavigationVm)
                #expect(flowVm.initialStep == .router(action: .withdrawalChoice))
                #expect(flowVm.config == MockTerminationData.withdrawalConfig)
                #expect(flowVm.terminateInsuranceViewModel === terminateVm)
                #expect(mockClient.events.isEmpty, "the survey must not be fetched before the member chooses")
                #expect(!terminateVm.isLoading)
            }

            await expectReleased()
        }

        @Test
        func startWithSingleConfigWithoutWithdrawalOpensSurvey() async {
            await recordingErrors {
                let mockClient = registerMockClient()
                let terminateVm = TerminateInsuranceViewModel()
                vm = terminateVm

                try await terminateVm.start(with: [MockTerminationData.testConfig])

                let flowVm = try #require(terminateVm.flowNavigationVm)
                #expect(flowVm.initialStep == .router(action: .survey))
                #expect(flowVm.surveyData == MockTerminationData.terminateSurveyData)
                #expect(mockClient.events == [.getTerminationSurvey(contractId: "contract-123")])
            }

            await expectReleased()
        }

        @Test
        func startWithMultipleConfigsIncludingWithdrawalOpensSelectInsurance() async {
            await recordingErrors {
                let mockClient = registerMockClient()
                let terminateVm = TerminateInsuranceViewModel()
                vm = terminateVm
                let configs = [MockTerminationData.withdrawalConfig, MockTerminationData.testConfig]

                try await terminateVm.start(with: configs)

                let flowVm = try #require(terminateVm.flowNavigationVm)
                #expect(flowVm.initialStep == .router(action: .selectInsurance(configs: configs)))
                #expect(mockClient.events.isEmpty)
            }

            await expectReleased()
        }

        @discardableResult
        private func registerMockClient() -> MockTerminateContractsClient {
            let mockClient = MockTerminateContractsClient()
            sut = mockClient
            Dependencies.shared.add(module: Module { () -> TerminateContractsClient in mockClient })
            return mockClient
        }

        // Not deinit: this has to suspend before it reads sut.
        private func expectReleased() async {
            #expect(vm == nil, "the terminate insurance view model must not outlive the test that created it")
            Dependencies.shared.remove(for: TerminateContractsClient.self)
            await delay(0.00001)
            #expect(sut == nil, "the mock client must not outlive the test that created it")
        }
    }
}

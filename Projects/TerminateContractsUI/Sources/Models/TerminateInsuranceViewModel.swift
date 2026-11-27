import ChangeTierUI
import Combine
import Foundation
import Observation
import TerminateContractsCore

@MainActor
@Observable
public class TerminateInsuranceViewModel {
    var flowNavigationVm: TerminationFlowNavigationViewModel?
    var changeTierInput: ChangeTierInput?
    public var isLoading: Bool = false
    private let service = TerminateContractsService()
    public init() {}

    public func start(with configs: [TerminationConfirmConfig]) async throws {
        isLoading = true
        defer {
            isLoading = false
        }
        if configs.count == 1, let config = configs.first {
            if config.isWithdrawalOnly {
                let withdrawal = try await service.getContractWithdrawal(contractId: config.contractId)
                flowNavigationVm = .init(
                    config: config,
                    withdrawal: withdrawal,
                    terminateInsuranceViewModel: self
                )
            } else if config.supportsWithdrawal {
                flowNavigationVm = .init(
                    withdrawalChoiceFor: config,
                    terminateInsuranceViewModel: self
                )
            } else {
                let surveyData = try await service.getTerminationSurvey(contractId: config.contractId)
                flowNavigationVm = .init(
                    config: config,
                    surveyData: surveyData,
                    terminateInsuranceViewModel: self
                )
            }
        } else {
            flowNavigationVm = TerminationFlowNavigationViewModel(
                configs: configs,
                terminateInsuranceViewModel: self
            )
        }
    }
}

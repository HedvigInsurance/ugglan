import ChangeTier
import Combine
import Foundation
import Observation

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
            let surveyData = try await service.getTerminationSurvey(contractId: config.contractId)
            flowNavigationVm = .init(
                config: config,
                surveyData: surveyData,
                terminateInsuranceViewModel: self
            )
        } else {
            flowNavigationVm = TerminationFlowNavigationViewModel(
                configs: configs,
                terminateInsuranceViewModel: self
            )
        }
    }
}

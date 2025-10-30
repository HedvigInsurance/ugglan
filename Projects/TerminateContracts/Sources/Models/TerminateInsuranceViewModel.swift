import ChangeTier
import Combine
import Foundation

@MainActor
public class TerminateInsuranceViewModel: ObservableObject {
    private let terminateContractsService = TerminateContractsService()
    @Published var flowNavigationVm: TerminationFlowNavigationViewModel?
    @Published var changeTierInput: ChangeTierInput?
    public init() {}

    public func start(with configs: [TerminationConfirmConfig]) async throws {
        if configs.count > 1 {
            flowNavigationVm = TerminationFlowNavigationViewModel(
                configs: configs,
                terminateInsuranceViewModel: self
            )
        } else if let config = configs.first {
            if let stepResponse = try await startTermination(config: config) {
                flowNavigationVm = TerminationFlowNavigationViewModel(
                    stepResponse: stepResponse,
                    config: config,
                    terminateInsuranceViewModel: self
                )
            }
        }
    }

    @MainActor
    private func startTermination(config: TerminationConfirmConfig) async throws -> TerminateStepResponse? {
        let data = try await terminateContractsService.startTermination(contractId: config.contractId)
        return data
    }
}

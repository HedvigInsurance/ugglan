import ChangeTier
import Combine
import Foundation
import hCore

public class TerminateInsuranceViewModel: ObservableObject {
    @Inject var terminateContractsService: TerminateContractsClient
    @Published var flowNavigationVm: TerminationFlowNavigationViewModel?
    @Published var changeTierInput: ChangeTierInput?
    public init() {}

    public func start(with configs: [TerminationConfirmConfig]) {
        if configs.count > 1 {
            flowNavigationVm = .init(
                configs: configs,
                terminateInsuranceViewModel: self
            )
        } else if let config = configs.first {
            Task { @MainActor in
                if let stepResponse = await startTermination(config: config) {
                    flowNavigationVm = .init(
                        stepResponse: stepResponse,
                        config: config,
                        terminateInsuranceViewModel: self
                    )
                }
            }
        }
    }

    @MainActor
    func startTermination(config: TerminationConfirmConfig) async -> TerminateStepResponse? {
        do {
            let data = try await terminateContractsService.startTermination(contractId: config.contractId)
            return data
        } catch {

        }
        return nil
    }
}

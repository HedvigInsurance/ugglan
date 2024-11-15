import Combine
import Foundation
import hCore

public class TerminateInsuranceViewModel: ObservableObject {
    @Published var initialStep: ActionStepWrapper?
    @Inject var terminateContractsService: TerminateContractsClient

    public init() {}

    public func start(with configs: [TerminationConfirmConfig]) {
        if configs.count > 1 {
            initialStep = .init(
                actionWrapper: .init(action: .router(action: .selectInsurance(configs: configs))),
                config: configs,
                response: nil
            )
        } else if let config = configs.first {
            Task {
                let stepResponse = await startTermination(config: config)
                if let stepResponse {
                    initialStep = .init(config: configs, response: stepResponse)
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

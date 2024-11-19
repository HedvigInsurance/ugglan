import ChangeTier
import Combine
import Foundation
import hCore

public class TerminateInsuranceViewModel: ObservableObject {
    @Inject var terminateContractsService: TerminateContractsClient
    @Published var flowNavigationVm: TerminationFlowNavigationViewModel?
    @Published var changeTierInput: ChangeTierInput?
    @Published var context: String = ""
    @Published var progress: Float?
    @Published var previousProgress: Float?
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

    func getInitialStep(data: TerminateStepResponse, config: TerminationConfirmConfig) -> TerminationFlowActionWrapper {
        self.context = data.context
        self.previousProgress = data.progress
        self.progress = data.progress

        switch data.step {
        case let .setTerminationDateStep(model):
            return .init(action: .router(action: .terminationDate(model: model)))
        case let .setSuccessStep(model):
            return .init(action: .final(action: .success(model: model)))
        case let .setFailedStep(model):
            return .init(action: .final(action: .fail(model: model)))
        case let .setTerminationSurveyStep(model):
            return .init(action: .router(action: .surveyStep(model: model)))
        case .openTerminationUpdateAppScreen:
            return .init(action: .final(action: .updateApp))
        default:
            return .init(action: .final(action: .fail(model: nil)))
        }
    }
}

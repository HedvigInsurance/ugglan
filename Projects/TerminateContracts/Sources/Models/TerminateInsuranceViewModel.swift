import ChangeTier
import Combine
import Foundation

@MainActor
public class TerminateInsuranceViewModel: ObservableObject {
    @Published var flowNavigationVm: TerminationFlowNavigationViewModel?
    @Published var changeTierInput: ChangeTierInput?
    public init() {}

    public func start(with configs: [TerminationConfirmConfig]) {
        flowNavigationVm = TerminationFlowNavigationViewModel(
            configs: configs,
            terminateInsuranceViewModel: self
        )
    }
}

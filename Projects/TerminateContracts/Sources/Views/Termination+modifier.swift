import ChangeTier
import Foundation
import SwiftUI
import hCoreUI

struct ActionStepWrapper: Equatable, Identifiable {
    var id = UUID()
    var actionWrapper: TerminationFlowActionWrapper? = nil
    var config: [TerminationConfirmConfig]
    var response: TerminateStepResponse?
}

extension View {
    public func handleTerminateInsurance(
        vm: TerminateInsuranceViewModel,
        navigationVm: TerminationFlowNavigationViewModel,
        onDismiss: @escaping (DismissTerminationAction) -> Void
    ) -> some View {
        modifier(TerminateInsurance(vm: vm, onDismiss: onDismiss))
            .environmentObject(navigationVm)
    }
}

struct TerminateInsurance: ViewModifier {
    @ObservedObject var vm: TerminateInsuranceViewModel
    @EnvironmentObject var navigationVm: TerminationFlowNavigationViewModel
    @State var context: String = ""
    @State var progress: Float?
    @State var previousProgress: Float?

    let onDismiss: (DismissTerminationAction) -> Void
    func body(content: Content) -> some View {
        content
            .modally(
                item: $vm.initialStep,
                options: .constant(.alwaysOpenOnTop)
            ) { item in
                if item.config.count > 1 {
                    let _ = navigationVm.hasSelectInsuranceStep = true

                    TerminationFlowNavigation(
                        initialStep: .router(action: .selectInsurance(configs: item.config)),
                        configs: item.config,
                        context: context,
                        progress: progress,
                        previousProgress: previousProgress
                    )
                    .task {
                        navigationVm.isFlowPresented = { dismissType in
                            onDismiss(dismissType)
                        }
                    }
                } else if let config = item.config.first {
                    let _ = navigationVm.hasSelectInsuranceStep = false
                    let action = getInitialStep(
                        data: item.response
                            ?? .init(
                                context: "",
                                step: .setFailedStep(model: TerminationFlowFailedNextModel(id: "")),
                                progress: nil
                            ),
                        config: config
                    )

                    TerminationFlowNavigation(
                        initialStep: action.action,
                        configs: item.config,
                        context: context,
                        progress: progress,
                        previousProgress: previousProgress
                    )
                    .task {
                        navigationVm.isFlowPresented = { dismissType in
                            onDismiss(dismissType)
                        }
                    }
                }
            }
            .modally(item: $navigationVm.changeTierInput) { item in
                ChangeTierNavigation(input: item)
            }
    }

    func getInitialStep(data: TerminateStepResponse, config: TerminationConfirmConfig) -> TerminationFlowActionWrapper {
        self.context = data.context
        self.previousProgress = navigationVm.progress
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

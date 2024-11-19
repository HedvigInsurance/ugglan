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
        onDismiss: @escaping (DismissTerminationAction) -> Void
    ) -> some View {
        modifier(TerminateInsurance(vm: vm, onDismiss: onDismiss))
    }
}

struct TerminateInsurance: ViewModifier {
    @ObservedObject var vm: TerminateInsuranceViewModel
    @State var context: String = ""
    @State var progress: Float?
    @State var previousProgress: Float?

    @State var isFlowPresented: (DismissTerminationAction) -> Void = { _ in }

    let onDismiss: (DismissTerminationAction) -> Void
    func body(content: Content) -> some View {
        content
            .modally(
                item: $vm.initialStep,
                options: .constant(.alwaysOpenOnTop)
            ) { item in
                if item.config.count > 1 {
                    TerminationFlowNavigation(
                        initialStep: .router(action: .selectInsurance(configs: item.config)),
                        configs: item.config,
                        context: context,
                        progress: progress,
                        previousProgress: previousProgress,
                        hasSelectInsuranceStep: true,
                        isFlowPresented: isFlowPresented
                    )
                    .task {
                        self.isFlowPresented = { dismissType in
                            onDismiss(dismissType)
                        }
                    }
                } else if let config = item.config.first {
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
                        previousProgress: previousProgress,
                        hasSelectInsuranceStep: false
                    )
                    .task {
                        self.isFlowPresented = { dismissType in
                            onDismiss(dismissType)
                        }
                    }
                }
            }
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

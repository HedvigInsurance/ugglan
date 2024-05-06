import Combine
import SwiftUI
import hCore
import hCoreUI

struct TerminationSurveyScreen: View {
    @ObservedObject var vm: SurveyScreenViewModel
    @Namespace var animationNamespace
    var body: some View {
        hForm {}
            .hFormTitle(
                title: .init(
                    .small,
                    .title3,
                    L10n.terminationFlowCancellationTitle,
                    alignment: .leading
                ),
                subTitle: .init(
                    .small,
                    .title3,
                    L10n.terminationFlowReason
                )
            )
            .hFormAttachToBottom {
                hSection {
                    VStack(spacing: 16) {
                        VStack(spacing: 4) {
                            ForEach(vm.options) { option in
                                ZStack {
                                    VStack(spacing: 4) {
                                        hRadioField(
                                            id: option.id,
                                            content: {
                                                hText(option.title)
                                            },
                                            selected: $vm.selected
                                        )
                                        .zIndex(1)
                                        if let suggestion = option.suggestion, option.id == vm.selectedOption?.id {
                                            buildInfo(for: suggestion)
                                                .matchedGeometryEffect(id: "buildInfo", in: animationNamespace)
                                        }

                                        if let feedBack = vm.allFeedBackViewModels[option.id],
                                            option.id == vm.selectedOption?.id
                                        {
                                            ZStack {
                                                TerminationFlowSurveyStepFeedBackView(
                                                    vm: feedBack
                                                )
                                                .matchedGeometryEffect(id: "feedBack", in: animationNamespace)
                                            }
                                        }
                                    }
                                }

                            }
                        }
                        hButton.LargeButton(type: .primary) {
                            vm.continueClicked()
                        } content: {
                            hText(L10n.generalContinueButton)
                        }
                        .disabled(!vm.continueEnabled)
                    }

                }
                .sectionContainerStyle(.transparent)
            }
    }

    @ViewBuilder
    func buildInfo(for suggestion: TerminationFlowSurveyStepSuggestion) -> some View {
        switch suggestion {
        case .action(let action):
            InfoCard(text: "action", type: .campaign)
                .buttons([
                    .init(
                        buttonTitle: L10n.dashboardRenewalPrompterBodyButton,
                        buttonAction: {

                        }
                    )
                ])
        case .redirect(let redirect):
            InfoCard(text: redirect.description, type: .campaign)
                .buttons([
                    .init(
                        buttonTitle: redirect.buttonTitle,
                        buttonAction: {

                        }
                    )
                ])
        }
    }
}

class SurveyScreenViewModel: ObservableObject {
    let options: [TerminationFlowSurveyStepModelOption]
    var allFeedBackViewModels = [String: TerminationFlowSurveyStepFeedBackViewModel]()

    @PresentableStore var store: TerminationContractStore

    @Published var text: String = "test"
    @Published var continueEnabled = true
    @Published var selected: String?
    @Published var selectedOption: TerminationFlowSurveyStepModelOption?
    @Published var selectedFeedBackViewModel: TerminationFlowSurveyStepFeedBackViewModel?

    private var selectedFeedBackViewModelCancellable: AnyCancellable?
    private var selectedOptionCancellable: AnyCancellable?
    init(options: [TerminationFlowSurveyStepModelOption]) {
        self.options = options

        selectedOptionCancellable =
            $selected
            .sink(receiveValue: { [weak self] value in
                self?.handleSelection(of: value)
            })
    }

    private func handleSelection(of option: String?) {
        let selectedOption: TerminationFlowSurveyStepModelOption? = options.first(where: { $0.id == option })
        let selectedFeedBackViewModel: TerminationFlowSurveyStepFeedBackViewModel? = {
            if let selectedOption {
                if let feedbackVm = allFeedBackViewModels[selectedOption.id] {
                    return feedbackVm
                }
                if let feedBack = selectedOption.feedBack {
                    let model = TerminationFlowSurveyStepFeedBackViewModel(feedback: feedBack)
                    allFeedBackViewModels[selectedOption.id] = model
                    return model
                }
            }
            return nil
        }()
        print("SETTINGS")
        selectedFeedBackViewModelCancellable = selectedFeedBackViewModel?.$text
            .sink(receiveValue: { [weak self] value in
                print(value)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self?.checkContinueButtonStatus()
                }
            })
        withAnimation {
            self.selectedOption = selectedOption
            self.selectedFeedBackViewModel = selectedFeedBackViewModel
        }
        checkContinueButtonStatus()
    }

    func checkContinueButtonStatus() {
        let status: Bool = {
            guard let selectedOption = selectedOption else { return false }
            guard let feedBack = selectedFeedBackViewModel else { return true }
            if feedBack.required && feedBack.text.count < 10 {
                return false
            }
            return true
        }()

        continueEnabled = status
    }

    func continueClicked() {
        if let subOptions = selectedOption?.subOptions {
            store.send(.navigationAction(action: .openTerminationSurveyStep(options: subOptions)))
        } else if let selectedOption {
            store.send(.submitSurvey(option: selectedOption.id, feedback: nil))
        }
    }
}

#Preview{
    let options = [
        TerminationFlowSurveyStepModelOption(
            id: "optionId",
            title: "Option title",
            suggestion: .action(
                action: .init(
                    id: "actionId",
                    action: .updateAddress
                )
            ),
            feedBack: nil,
            subOptions: nil
        ),
        .init(
            id: "optionId2",
            title: "Option title 2",
            suggestion: nil,
            feedBack: .init(
                id: "feedbackId",
                isRequired: true
            ),
            subOptions: nil
        ),
        .init(
            id: "optionId3",
            title: "Option title 3",
            suggestion: nil,
            feedBack: .init(
                id: "feedbackId",
                isRequired: true
            ),
            subOptions: nil
        ),
        .init(
            id: "optionId4",
            title: "Option title 4",
            suggestion: nil,
            feedBack: .init(
                id: "feedbackId",
                isRequired: true
            ),
            subOptions: nil
        ),
    ]

    return NavigationView {
        TerminationSurveyScreen(vm: .init(options: options))
            .navigationBarTitleDisplayMode(.inline)
    }
}

struct TerminationFlowSurveyStepFeedBackView: View {
    @ObservedObject var vm: TerminationFlowSurveyStepFeedBackViewModel
    var body: some View {
        ZStack {
            hFreeTextInputField2(
                selectedValue: vm.text,
                placeholder: "Please let us know more...",
                required: vm.required,
                maxCharacters: 140
            ) { text in
                print("TEXT IS \(text)")
                vm.error = vm.required && text.isEmpty ? "Please enter your feedback" : nil
                vm.text = text
            }
            .hTextFieldError(vm.error)
        }
        .cornerRadius(12)
        .frame(height: 128)
    }
}

class TerminationFlowSurveyStepFeedBackViewModel: ObservableObject {
    @Published var text: String
    @Published var required: Bool
    @Published var error: String?

    init(feedback: TerminationFlowSurveyStepFeedback) {
        self.text = ""
        self.required = feedback.isRequired
    }
}

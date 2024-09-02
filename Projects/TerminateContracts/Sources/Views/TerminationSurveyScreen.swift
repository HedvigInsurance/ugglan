import Combine
import PresentableStore
import SwiftUI
import hCore
import hCoreUI

struct TerminationSurveyScreen: View {
    @ObservedObject var vm: SurveyScreenViewModel
    @Namespace var animationNamespace
    @EnvironmentObject var terminationFlowNavigationViewModel: TerminationFlowNavigationViewModel

    @PresentableStore var store: TerminationContractStore
    var body: some View {
        hForm {
            hSection {
                VStack(spacing: 16) {
                    VStack(spacing: 4) {
                        ForEach(vm.options) { option in
                            ZStack {
                                VStack(spacing: 4) {
                                    hRadioField(
                                        id: option.id,
                                        leftView: {
                                            hText(option.title).asAnyView
                                        },
                                        selected: $vm.selected
                                    )
                                    .hFieldSize(.medium)
                                    .zIndex(1)
                                    if let suggestion = option.suggestion, option.id == vm.selectedOption?.id {
                                        buildInfo(for: suggestion)
                                            .matchedGeometryEffect(id: "buildInfo", in: animationNamespace)
                                    }

                                    if let feedBack = vm.allFeedBackViewModels[option.id],
                                        option.id == vm.selectedOption?.id
                                    {
                                        TerminationFlowSurveyStepFeedBackView(
                                            vm: feedBack
                                        )
                                    }
                                }
                            }

                        }
                    }
                }
                .padding(.bottom, .padding16)
            }
            .sectionContainerStyle(.transparent)
        }
        .hFormTitle(
            title: .init(
                .small,
                .body2,
                L10n.terminationFlowCancellationTitle,
                alignment: .leading
            ),
            subTitle: .init(
                .small,
                .body2,
                vm.subtitleType.title
            )
        )
        .hFormIgnoreKeyboard()
        .hFormContentPosition(.bottom)
        .hFormDontUseInitialAnimation
        .hFormIgnoreScrollOffsetChanges
        .hFormAttachToBottom {
            hSection {
                hButton.LargeButton(type: .primary) { [weak vm] in
                    vm?.continueClicked()
                } content: {
                    hText(L10n.generalContinueButton)
                }
                .disabled(!vm.continueEnabled)
            }
            .sectionContainerStyle(.transparent)
        }
        .hTrackLoading(TerminationContractStore.self, action: .sendSurvey)
    }

    @ViewBuilder
    func buildInfo(for suggestion: TerminationFlowSurveyStepSuggestion) -> some View {
        switch suggestion {
        case .action(let action):
            InfoCard(text: action.description, type: .campaign)
                .buttons([
                    .init(
                        buttonTitle: action.buttonTitle,
                        buttonAction: { [weak terminationFlowNavigationViewModel] in
                            terminationFlowNavigationViewModel?.redirectAction = action.action
                        }
                    )
                ])
                .hButtonIsLoading(false)
        case .redirect(let redirect):
            InfoCard(text: redirect.description, type: .campaign)
                .buttons([
                    .init(
                        buttonTitle: redirect.buttonTitle,
                        buttonAction: { [weak terminationFlowNavigationViewModel] in
                            if let url = URL(string: redirect.url) {
                                terminationFlowNavigationViewModel?.redirectUrl = url
                            }
                        }
                    )
                ])
                .hButtonIsLoading(false)
        }
    }
}

class SurveyScreenViewModel: ObservableObject {
    let options: [TerminationFlowSurveyStepModelOption]
    let subtitleType: SurveyScreenSubtitleType
    var allFeedBackViewModels = [String: TerminationFlowSurveyStepFeedBackViewModel]()

    @PresentableStore var store: TerminationContractStore

    @Published var text: String = "test"
    @Published var continueEnabled = true
    @Published var selected: String?
    @Published var selectedOption: TerminationFlowSurveyStepModelOption?
    @Published var selectedFeedBackViewModel: TerminationFlowSurveyStepFeedBackViewModel?

    private var selectedFeedBackViewModelCancellable: AnyCancellable?
    private var selectedOptionCancellable: AnyCancellable?
    init(options: [TerminationFlowSurveyStepModelOption], subtitleType: SurveyScreenSubtitleType) {
        self.options = options
        self.subtitleType = subtitleType
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
        selectedFeedBackViewModelCancellable = selectedFeedBackViewModel?.$text
            .sink(receiveValue: { [weak self] value in
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
            guard selectedOption != nil else { return false }
            guard let feedBack = selectedFeedBackViewModel else { return true }
            if feedBack.required && feedBack.text.count < 10 {
                return false
            }
            return true
        }()

        if selectedOption?.suggestion != nil {
            continueEnabled = false
        } else {
            continueEnabled = status
        }
    }

    func continueClicked() {
        if let subOptions = selectedOption?.subOptions, !subOptions.isEmpty {
            store.send(
                .navigationAction(action: .openTerminationSurveyStep(options: subOptions, subtitleType: .generic))
            )
        } else if let selectedOption {
            store.send(.submitSurvey(option: selectedOption.id, feedback: selectedFeedBackViewModel?.text))
        }
    }
}

#Preview{
    Localization.Locale.currentLocale.send(.en_SE)
    let options = [
        TerminationFlowSurveyStepModelOption(
            id: "optionId",
            title: "Option title",
            suggestion: .action(
                action: .init(
                    id: "actionId",
                    action: .updateAddress,
                    description: "description",
                    buttonTitle: "button title"
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
        TerminationSurveyScreen(vm: .init(options: options, subtitleType: .default))
            .navigationBarTitleDisplayMode(.inline)
    }
}

struct TerminationFlowSurveyStepFeedBackView: View {
    @ObservedObject var vm: TerminationFlowSurveyStepFeedBackViewModel
    var body: some View {
        hTextView(
            selectedValue: vm.text,
            placeholder: L10n.terminationSurveyFeedbackHint,
            required: vm.required,
            maxCharacters: 2000
        ) { [weak vm] text in guard let vm else { return }
            vm.error = vm.required && text.isEmpty ? L10n.terminationSurveyFeedbackInfo : nil
            vm.text = text
        }
        .hTextFieldError(vm.error)
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

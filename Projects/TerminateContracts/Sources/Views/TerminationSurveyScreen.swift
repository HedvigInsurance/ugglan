import Combine
import hCore
import hCoreUI
import SwiftUI

struct TerminationSurveyScreen: View {
    @ObservedObject var vm: SurveyScreenViewModel
    @EnvironmentObject var terminationFlowNavigationViewModel: TerminationFlowNavigationViewModel

    var body: some View {
        hForm {
            content
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
        .hFormContentPosition(.bottom)
        .hFormAlwaysAttachToBottom {
            hSection {
                hContinueButton {
                    continueClicked()
                }
                .disabled(!vm.continueEnabled)
                .accessibilityHint(
                    vm.selected == nil
                        ? L10n.voiceoverPickerInfo(L10n.generalContinueButton)
                        : (L10n.voiceoverOptionSelected + (vm.selectedOption?.title ?? ""))
                )
            }
            .sectionContainerStyle(.transparent)
        }
        .trackErrorState(for: $vm.viewState)
        .hButtonIsLoading(vm.viewState == .loading)
    }

    private var content: some View {
        hSection {
            VStack(spacing: 4) {
                ForEach(vm.options) { option in
                    ZStack {
                        VStack(spacing: 4) {
                            hRadioField(
                                id: option.id,
                                itemModel: .init(title: option.title, subTitle: nil),
                                leftView: nil,
                                selected: $vm.selected
                            )
                            .hFieldSize(.medium)
                            .zIndex(1)
                        }
                    }
                }
                if let suggestion = vm.selectedOption?.suggestion {
                    suggestionView(for: suggestion)
                }

                if let optionId = vm.selectedOption?.id, let feedBack = vm.allFeedBackViewModels[optionId],
                   optionId == vm.selectedOption?.id
                {
                    TerminationFlowSurveyStepFeedBackView(
                        vm: feedBack
                    )
                }
            }
        }
        .sectionContainerStyle(.transparent)
    }

    @ViewBuilder
    func suggestionView(for suggestion: TerminationFlowSurveyStepSuggestion) -> some View {
        switch suggestion {
        case let .action(action):
            InfoCard(text: action.description, type: action.type.notificationType)
                .buttons([
                    .init(
                        buttonTitle: action.buttonTitle,
                        buttonAction: { [weak terminationFlowNavigationViewModel] in
                            terminationFlowNavigationViewModel?.redirectAction = action.action
                        }
                    ),
                ])
                .hButtonIsLoading(terminationFlowNavigationViewModel.redirectActionLoadingState == .loading)
        case let .redirect(redirect):
            InfoCard(text: redirect.description, type: redirect.type.notificationType)
                .buttons([
                    .init(
                        buttonTitle: redirect.buttonTitle,
                        buttonAction: { [weak terminationFlowNavigationViewModel] in
                            if let url = URL(string: redirect.url) {
                                terminationFlowNavigationViewModel?.redirectUrl = url
                            }
                        }
                    ),
                ])
                .hButtonIsLoading(false)
        case let .suggestionInfo(info):
            InfoCard(text: info.description, type: info.type.notificationType)
        }
    }

    func continueClicked() {
        if let subOptions = vm.selectedOption?.subOptions, !subOptions.isEmpty {
            let currentProgress = terminationFlowNavigationViewModel.progress ?? 0
            terminationFlowNavigationViewModel.previousProgress = terminationFlowNavigationViewModel.progress

            let progress = (currentProgress + 0.2)
            terminationFlowNavigationViewModel.progress =
                (progress / 1) * (terminationFlowNavigationViewModel.hasSelectInsuranceStep ? 0.75 : 1)
                    + (terminationFlowNavigationViewModel.hasSelectInsuranceStep ? 0.25 : 0)

            terminationFlowNavigationViewModel.terminationSurveyStepModel?.options = subOptions
            terminationFlowNavigationViewModel.terminationSurveyStepModel?.subTitleType = .generic

            terminationFlowNavigationViewModel.router.push(
                TerminationFlowRouterActions.surveyStep(
                    model: terminationFlowNavigationViewModel.terminationSurveyStepModel
                )
            )
        } else if let selectedOption = vm.selectedOption {
            Task {
                let step = await vm.submitSurvey(
                    context: terminationFlowNavigationViewModel.currentContext ?? "",
                    option: selectedOption.id,
                    inputData: vm.selectedFeedBackViewModel?.text
                )

                terminationFlowNavigationViewModel.navigate(data: step, fromSelectInsurance: false)
            }
        }
    }
}

@MainActor
class SurveyScreenViewModel: ObservableObject {
    let options: [TerminationFlowSurveyStepModelOption]
    let subtitleType: SurveyScreenSubtitleType
    var allFeedBackViewModels = [String: TerminationFlowSurveyStepFeedBackViewModel]()

    @Published var continueEnabled = false

    @Published var selected: String? {
        didSet {
            handleSelection(of: selected)
        }
    }

    @Published var selectedOption: TerminationFlowSurveyStepModelOption?
    @Published var selectedFeedBackViewModel: TerminationFlowSurveyStepFeedBackViewModel? {
        didSet {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.checkContinueButtonStatus()
            }
        }
    }

    @Published var viewState: ProcessingState = .success
    private let terminateContractsService = TerminateContractsService()

    init(options: [TerminationFlowSurveyStepModelOption], subtitleType: SurveyScreenSubtitleType) {
        self.options = options
        self.subtitleType = subtitleType
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
        withAnimation {
            self.selectedOption = selectedOption
            self.selectedFeedBackViewModel = selectedFeedBackViewModel
        }
        checkContinueButtonStatus()
    }

    @MainActor
    func submitSurvey(context: String, option: String, inputData: String?) async -> TerminateStepResponse {
        withAnimation {
            viewState = .loading
        }
        do {
            let data = try await terminateContractsService.sendSurvey(
                terminationContext: context,
                option: option,
                inputData: inputData
            )
            withAnimation {
                viewState = .success
            }
            return data
        } catch {
            withAnimation {
                self.viewState = .error(
                    errorMessage: error.localizedDescription
                )
            }
            return TerminateStepResponse(context: context, step: .setFailedStep(model: .init(id: "")), progress: nil)
        }
    }

    func checkContinueButtonStatus() {
        let status: Bool = {
            guard selectedOption != nil else { return false }
            guard let feedBack = selectedFeedBackViewModel else { return true }
            if feedBack.required, feedBack.text.count < 10 {
                return false
            }
            return true
        }()

        if let suggestion = selectedOption?.suggestion {
            switch suggestion {
            case let .action(action):
                if action.action == .updateAddress {
                    continueEnabled = false
                }
                continueEnabled = true
            default:
                continueEnabled = true
            }
        } else {
            continueEnabled = status
        }
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> TerminateContractsClient in TerminateContractsClientDemo() })
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
                    buttonTitle: "button title",
                    type: .offer
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
            suggestion: .suggestionInfo(
                info: .init(
                    id: "id",
                    description: "description",
                    type: .info
                )
            ),
            feedBack: nil,
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
            .environmentObject(TerminationFlowNavigationViewModel(configs: [], terminateInsuranceViewModel: .init()))
    }
}

struct TerminationFlowSurveyStepFeedBackView: View {
    @ObservedObject var vm: TerminationFlowSurveyStepFeedBackViewModel
    var body: some View {
        hTextView(
            selectedValue: vm.text,
            placeholder: L10n.terminationSurveyFeedbackHint,
            popupPlaceholder: L10n.terminationSurveyFeedbackPopoverHint,
            required: vm.required,
            maxCharacters: 2000,
            enableTransition: false
        ) { [weak vm] text in
            guard let vm else { return }
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
        text = ""
        required = feedback.isRequired
    }
}

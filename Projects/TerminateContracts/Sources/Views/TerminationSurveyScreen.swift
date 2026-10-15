import SwiftUI
import hCore
import hCoreUI

struct TerminationSurveyScreen: View {
    @Bindable var vm: SurveyScreenViewModel
    @Environment(TerminationFlowNavigationViewModel.self) var terminationFlowNavigationViewModel

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
    func suggestionView(for suggestion: TerminationSuggestion) -> some View {
        if suggestion.isBlocking {
            InfoCard(text: suggestion.description, type: .campaign)
                .buttons([
                    .init(
                        buttonTitle: suggestion.buttonTitle,
                        buttonAction: { [weak terminationFlowNavigationViewModel] in
                            terminationFlowNavigationViewModel?.handleSuggestion(suggestion)
                        }
                    )
                ])
                .hButtonIsLoading(terminationFlowNavigationViewModel.redirectActionLoadingState == .loading)
        } else if suggestion.type == .info {
            InfoCard(text: suggestion.description, type: .info)
        }
    }

    func continueClicked() {
        guard let selectedOption = vm.selectedOption else { return }
        let comment = vm.selectedFeedBackViewModel?.text

        if let redirectionRoute = TerminationSurveyRedirectionRoute(option: selectedOption, comment: comment) {
            terminationFlowNavigationViewModel.router.push(redirectionRoute)
        } else {
            terminationFlowNavigationViewModel.continueSurvey(option: selectedOption, comment: comment)
        }
    }
}

@MainActor
@Observable
class SurveyScreenViewModel {
    let options: [TerminationSurveyOption]
    let subtitleType: SurveyScreenSubtitleType
    @ObservationIgnored var allFeedBackViewModels = [String: TerminationFlowSurveyStepFeedBackViewModel]()
    @ObservationIgnored private var feedbackTextWatcher: ObservationWatcher?

    var continueEnabled = false

    var selected: String? {
        didSet {
            handleSelection(of: selected)
        }
    }

    var selectedOption: TerminationSurveyOption?
    var selectedFeedBackViewModel: TerminationFlowSurveyStepFeedBackViewModel? {
        didSet {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.checkContinueButtonStatus()
            }
        }
    }

    init(options: [TerminationSurveyOption], subtitleType: SurveyScreenSubtitleType) {
        self.options = options
        self.subtitleType = subtitleType
    }

    private func handleSelection(of option: String?) {
        let selectedOption: TerminationSurveyOption? = options.first(where: { $0.id == option })
        let selectedFeedBackViewModel: TerminationFlowSurveyStepFeedBackViewModel? = {
            if let selectedOption {
                if let feedbackVm = allFeedBackViewModels[selectedOption.id] {
                    return feedbackVm
                }
                if selectedOption.feedbackRequired {
                    let model = TerminationFlowSurveyStepFeedBackViewModel(required: true)
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
        feedbackTextWatcher = selectedFeedBackViewModel.map { feedBackViewModel in
            ObservationWatcher { [weak feedBackViewModel] in
                _ = feedBackViewModel?.text
            } onChange: { [weak self] in
                self?.checkContinueButtonStatus()
            }
        }
        checkContinueButtonStatus()
    }

    func checkContinueButtonStatus() {
        let status: Bool = {
            guard let selectedOption else { return false }
            if let suggestion = selectedOption.suggestion, suggestion.isBlocking {
                return false
            }
            return true
        }()

        continueEnabled = status
    }
}

#Preview {
    Localization.Locale.currentLocale.send(.en_SE)
    let options = [
        TerminationSurveyOption(
            id: "optionId",
            title: "Option title",
            feedbackRequired: false,
            suggestion: .init(type: .updateAddress, description: "description", url: nil),
            subOptions: []
        ),
        TerminationSurveyOption(
            id: "optionId2",
            title: "Option title 2",
            feedbackRequired: true,
            suggestion: nil,
            subOptions: []
        ),
        TerminationSurveyOption(
            id: "optionId3",
            title: "Option title 3",
            feedbackRequired: false,
            suggestion: .init(type: .info, description: "description", url: nil),
            subOptions: []
        ),
        TerminationSurveyOption(
            id: "optionId4",
            title: "Option title 4",
            feedbackRequired: true,
            suggestion: nil,
            subOptions: []
        ),
    ]

    return NavigationView {
        TerminationSurveyScreen(vm: .init(options: options, subtitleType: .default))
            .navigationBarTitleDisplayMode(.inline)
            .environment(TerminationFlowNavigationViewModel(configs: [], terminateInsuranceViewModel: .init()))
    }
}

struct TerminationFlowSurveyStepFeedBackView: View {
    @Bindable var vm: TerminationFlowSurveyStepFeedBackViewModel
    var body: some View {
        hTextView(
            selectedValue: vm.text,
            placeholder: L10n.terminationSurveyFeedbackHint,
            popupPlaceholder: L10n.terminationSurveyFeedbackPopoverHint,
            maxCharacters: 2000
        ) { [weak vm] text in
            guard let vm else { return }
            vm.error = vm.required && text.isEmpty ? L10n.terminationSurveyFeedbackInfo : nil
            vm.text = text
        }
        .hTextFieldError(vm.error)
    }
}

@Observable
class TerminationFlowSurveyStepFeedBackViewModel {
    var text: String
    var required: Bool
    var error: String?

    init(required: Bool) {
        text = ""
        self.required = required
    }
}

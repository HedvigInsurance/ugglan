import Combine
import SwiftUI
import hCore
import hCoreUI

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

    func continueClicked() {
        guard let selectedOption = vm.selectedOption else { return }

        if !selectedOption.subOptions.isEmpty {
            terminationFlowNavigationViewModel.router.push(selectedOption.subOptions)
        } else if let suggestion = selectedOption.suggestion, suggestion.isDeflect || suggestion.isBlocking {
            terminationFlowNavigationViewModel.handleSuggestion(suggestion)
        } else {
            terminationFlowNavigationViewModel.proceedAfterSurvey(
                optionId: selectedOption.id,
                comment: vm.selectedFeedBackViewModel?.text
            )
        }
    }
}

@MainActor
class SurveyScreenViewModel: ObservableObject {
    let options: [TerminationSurveyOption]
    let subtitleType: SurveyScreenSubtitleType
    var allFeedBackViewModels = [String: TerminationFlowSurveyStepFeedBackViewModel]()
    private var feedbackTextCancellable: AnyCancellable?

    @Published var continueEnabled = false

    @Published var selected: String? {
        didSet {
            handleSelection(of: selected)
        }
    }

    @Published var selectedOption: TerminationSurveyOption?
    @Published var selectedFeedBackViewModel: TerminationFlowSurveyStepFeedBackViewModel? {
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
        feedbackTextCancellable = selectedFeedBackViewModel?.$text
            .dropFirst()
            .sink { [weak self] _ in
                DispatchQueue.main.async {
                    self?.checkContinueButtonStatus()
                }
            }
        checkContinueButtonStatus()
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
            maxCharacters: 2000
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

    init(required: Bool) {
        text = ""
        self.required = required
    }
}

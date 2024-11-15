import Combine
import SwiftUI
import hCore
import hCoreUI

struct TerminationSurveyScreen: View {
    @ObservedObject var vm: SurveyScreenViewModel
    @Namespace var animationNamespace
    @EnvironmentObject var terminationFlowNavigationViewModel: TerminationFlowNavigationViewModel

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
                                    Group {
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
                                    .frame(minHeight: 120)
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
                    continueClicked()
                } content: {
                    hText(L10n.generalContinueButton)
                }
                .disabled(!vm.continueEnabled)
            }
            .sectionContainerStyle(.transparent)
        }
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
                .hButtonIsLoading(vm.viewState == .loading)
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

    func continueClicked() {
        if let subOptions = vm.selectedOption?.subOptions, !subOptions.isEmpty {
            let currentProgress = terminationFlowNavigationViewModel.progress ?? 0
            Task { @MainActor in
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
                //                await store.sendAsync(
                //                    .navigationAction(action: .openTerminationSurveyStep(options: subOptions, subtitleType: .generic))
                //                )
            }
        } else if let selectedOption = vm.selectedOption {
            /* TODO: IMPLEMENT */
            Task {
                let step = await vm.submitSurvey(
                    context: terminationFlowNavigationViewModel.currentContext ?? "",
                    option: selectedOption.id,
                    inputData: vm.selectedFeedBackViewModel?.text
                )

                if let step {
                    terminationFlowNavigationViewModel.navigate(data: step)
                }
            }
            //            store.send(.submitSurvey(option: selectedOption.id, feedback: selectedFeedBackViewModel?.text))
        }
    }
}

class SurveyScreenViewModel: ObservableObject {
    let options: [TerminationFlowSurveyStepModelOption]
    let subtitleType: SurveyScreenSubtitleType
    var allFeedBackViewModels = [String: TerminationFlowSurveyStepFeedBackViewModel]()

    @Published var text: String = "test"
    @Published var continueEnabled = true

    @Published var selected: String? {
        didSet {
            handleSelection(of: selected)
        }
    }

    @Published var selectedOption: TerminationFlowSurveyStepModelOption?
    @Published var selectedFeedBackViewModel: TerminationFlowSurveyStepFeedBackViewModel? {
        didSet {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.checkContinueButtonStatus()
            }
        }
    }

    @Published var viewState: ProcessingState = .success
    @Inject private var service: TerminateContractsClient

    //    private var selectedFeedBackViewModelCancellable: AnyCancellable?
    //    private var selectedOptionCancellable: AnyCancellable?

    init(options: [TerminationFlowSurveyStepModelOption], subtitleType: SurveyScreenSubtitleType) {
        self.options = options
        self.subtitleType = subtitleType
        //        selectedOptionCancellable =
        //            $selected
        //            .sink(receiveValue: { [weak self] value in
        //                self?.handleSelection(of: value)
        //            })
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
        //        selectedFeedBackViewModelCancellable = selectedFeedBackViewModel?.$text
        //            .sink(receiveValue: { [weak self] value in
        //                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        //                    self?.checkContinueButtonStatus()
        //                }
        //            })
        withAnimation {
            self.selectedOption = selectedOption
            self.selectedFeedBackViewModel = selectedFeedBackViewModel
        }
        checkContinueButtonStatus()
    }

    @MainActor
    public func submitSurvey(context: String, option: String, inputData: String?) async -> TerminateStepResponse? {
        withAnimation {
            viewState = .loading
        }
        //        Task { @MainActor in
        do {
            let data = try await service.sendSurvey(terminationContext: context, option: option, inputData: inputData)
            withAnimation {
                viewState = .success
            }
            return data
        } catch let error {
            withAnimation {
                self.viewState = .error(
                    errorMessage: error.localizedDescription
                )
            }
            //            }
            //            return
        }
        return nil
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
        self.text = ""
        self.required = feedback.isRequired
    }
}

import ChangeTier
import SwiftUI
import hCore
import hCoreUI

public struct SubmitClaimChatScreen: View {
    @StateObject var viewModel: SubmitClaimChatViewModel
    @EnvironmentObject var router: Router
    let messageId: String?

    public init(
        messageId: String?,
        goToClaimDetails: @escaping (String) -> Void
    ) {
        self.messageId = messageId
        _viewModel = StateObject(
            wrappedValue: .init(messageId: messageId, goToClaimDetails: goToClaimDetails)
        )
    }

    public var body: some View {
        successView.loading($viewModel.viewState)
            .hStateViewButtonConfig(
                .init(
                    actionButton: .init(buttonAction: {
                        Task { await viewModel.startClaim(for: messageId) }
                    }),
                    dismissButton: nil
                )
            )
    }

    private var successView: some View {
        Group {
            if #available(iOS 16.0, *) {
                scrollContent
                    .toolbarBackground(.hidden, for: .navigationBar)
            } else {
                scrollContent
            }
        }
        .detent(
            item: $viewModel.isDatePickerPresented,
            transitionType: .detent(style: [.height])
        ) { datePickerVm in
            DatePickerView(vm: datePickerVm)
                .embededInNavigation(options: .largeNavigationBar, tracking: self)
        }
        .detent(
            item: $viewModel.isSelectItemPresented,
            transitionType: .detent(style: [.height])
        ) { model in
            SubmitClaimSingleSelectScreen(viewModel: viewModel, values: model.values)
                .embededInNavigation(options: .largeNavigationBar, tracking: self)
        }
        .colorScheme(.light)
    }

    private var scrollContent: some View {
        ScrollViewReader { proxy in
            mainContent
                .task(id: viewModel.allSteps.last?.step.id) {
                    try? await Task.sleep(seconds: 0.05)
                    withAnimation { proxy.scrollTo("BOTTOM", anchor: .bottom) }
                }
                .onAppear {
                    proxy.scrollTo("BOTTOM", anchor: .bottom)
                }
                .onChange(of: viewModel.allSteps.count) { _ in
                    withAnimation { proxy.scrollTo("BOTTOM", anchor: .bottom) }
                }
        }
    }

    private var mainContent: some View {
        hForm {
            VStack(spacing: .padding16) {
                ForEach(viewModel.allSteps) { step in
                    HStack {
                        spacing(step.sender == .member)
                        VStack(alignment: .leading, spacing: 0) {
                            SubmitClaimChatMesageView(step: step, viewModel: viewModel)
                            switch step.step.content {
                            case .summary, .outcome:
                                EmptyView()
                            default:
                                senderStamp(step: step)
                            }
                        }
                        spacing(step.sender == .hedvig)
                    }
                    .id(step.step.id)
                }

                Color.clear.frame(height: 1).id("BOTTOM")
            }
            .padding(.horizontal, .padding16)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .hFormContentPosition(.top)
        .hFormBottomBackgroundColor(.aiPoweredGradient)
    }

    private var loadingView: some View {
        HStack { DotsActivityIndicator(.standard) }
            .frame(maxWidth: .infinity, maxHeight: 40, alignment: .leading)
            .padding(.horizontal, .padding16)
            .background(hBackgroundColor.primary.opacity(0.01))
            .edgesIgnoringSafeArea(.top)
            .useDarkColor
            .transition(.opacity.combined(with: .opacity).animation(.easeInOut(duration: 0.2)))
    }

    @ViewBuilder
    func spacing(_ addSpacing: Bool) -> some View {
        if addSpacing { Spacer() }
    }

    @ViewBuilder
    func senderStamp(step: SubmitChatStepModel) -> some View {
        if step.isLoading {
            loadingView
        } else if step.sender == .hedvig {
            HStack {
                Circle()
                    .frame(width: 16, height: 16)
                    .foregroundColor(hSignalColor.Green.element)
                hText("Hedvig AI Assistant", style: .label)
                    .foregroundColor(hTextColor.Opaque.secondary)
            }
            .padding(.leading, .padding16)
        }
    }
}

extension SubmitClaimChatScreen: TrackingViewNameProtocol {
    public var nameForTracking: String { "" }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> ClaimIntentClient in ClaimIntentClientDemo() })
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    return SubmitClaimChatScreen(messageId: nil, goToClaimDetails: { _ in })
}

@MainActor
public class SubmitClaimChatViewModel: ObservableObject {
    @Published var isDatePickerPresented: DatePickerViewModel?
    @Published var isSelectItemPresented: SingleItemModel?
    @Published var hasClaimBeenSubmitted: ClaimIntentStepContentSummary?
    @Published var viewState: ProcessingState = .loading

    @Published var currentStep: ClaimIntentStep?
    @Published var allSteps: [SubmitChatStepModel] = []
    @Published var intentId: String?
    @Published var audioRecordingUrl: URL?

    @Published var selectedDate = Date()
    @Published var selectedPrice = ""

    var dates: [(id: String, value: Date)] = []
    var purchasePrice: [(id: String, value: String)] = []
    var selectedValue: [SingleSelectValue] = []
    @Published var binaryValues: [(id: String, value: String)] = []
    var goToClaimDetails: (String) -> Void

    private let service = ClaimIntentService()

    init(
        messageId: String?,
        goToClaimDetails: @escaping (String) -> Void
    ) {
        self.goToClaimDetails = goToClaimDetails
        Task { await startClaim(for: messageId) }
    }

    func startClaim(for messageId: String?) async {
        withAnimation {
            viewState = .loading
        }
        do {
            if let data = try await service.startClaimIntent(sourceMessageId: messageId) {
                withAnimation {
                    intentId = data.id
                    data.sourceMessages.forEach { sourceMessage in
                        allSteps.append(
                            .init(
                                step: .init(content: .text, id: sourceMessage.id, text: sourceMessage.text),
                                sender: .member,
                                isLoading: false
                            )
                        )
                    }
                    showNextStep(for: data.currentStep)
                    viewState = .success
                }
            }
        } catch {
            withAnimation {
                self.viewState = .error(errorMessage: error.localizedDescription)
            }
        }
    }

    @MainActor func getNextStep() async {
        do {
            let data = try await service.getNextStep(claimIntentId: intentId ?? "")
            showNextStep(for: data)
        } catch {
            withAnimation {
                self.viewState = .error(errorMessage: error.localizedDescription)
            }
        }
    }

    func sendAudioReferenceToBackend(translatedText: String, url: String?, freeText: String?) async {
        do {
            if let data = try await service.claimIntentSubmitAudio(
                fileId: url,
                freeText: freeText,
                stepId: currentStep?.id ?? ""
            ) {
                showNextStep(for: data.currentStep)
            }
        } catch {
            withAnimation {
                self.viewState = .error(errorMessage: error.localizedDescription)
            }
        }
    }

    func submitFile(fileIds: [String]) async {
        do {
            let data = try await service.claimIntentSubmitFile(stepId: currentStep?.id ?? "", fildIds: fileIds)
            withAnimation {
                if let step = data?.currentStep {
                    if let lastStep = allSteps.last {
                        let updatedStep: SubmitChatStepModel = .init(
                            step: lastStep.step,
                            sender: lastStep.sender,
                            isLoading: lastStep.isLoading,
                            isEnabled: false
                        )
                        allSteps.removeLast()
                        allSteps.append(updatedStep)
                    }
                    showNextStep(for: step)
                }
            }
        } catch {
            withAnimation {
                self.viewState = .error(errorMessage: error.localizedDescription)
            }
        }
    }

    func displayTask(_ model: ClaimIntentStepContentTask) {
        if let currentStep {
            let newSteps = allSteps.filter({
                $0.step.id != currentStep.id
            })
            allSteps = newSteps
            allSteps.append(.init(step: currentStep, sender: .hedvig, isLoading: !model.isCompleted))
            Task {
                model.isCompleted ? await submitTask() : await getNextStep()
            }
        }
    }

    func displayFile(_ model: ClaimIntentStepContentFileUpload) {
        if let currentStep {
            let userStep: ClaimIntentStep = .init(
                content: .fileUpload(model: model),
                id: UUID().uuidString,
                text: currentStep.text
            )
            allSteps.append(.init(step: userStep, sender: .member, isLoading: false))
        }
    }

    func displayForm(_ model: ClaimIntentStepContentForm) {
        if let currentStep {
            let userStep: ClaimIntentStep = .init(
                content: .form(model: model),
                id: UUID().uuidString,
                text: currentStep.text
            )
            allSteps.append(.init(step: userStep, sender: .member, isLoading: false))
        }
    }

    func displayAudio(_ model: ClaimIntentStepContentAudioRecording) {
        if let currentStep {
            let memberAudioStep = SubmitChatStepModel(
                step: .init(
                    content: .audioRecording(model: .init(hint: model.hint, uploadURI: model.uploadURI)),
                    id: currentStep.id + "2",
                    text: currentStep.text
                ),
                sender: .member,
                isLoading: false
            )
            allSteps.append(memberAudioStep)
        }
    }

    func submitTask() async {
        do {
            let data = try await service.claimIntentSubmitTask(stepId: currentStep?.id ?? "")
            if let step = data?.currentStep {
                showNextStep(for: step)
            }
        } catch {
            print("Failed sending task completed:", error)
            withAnimation {
                self.viewState = .error(errorMessage: error.localizedDescription)
            }
        }
    }

    func submitForm(fields: [ClaimIntentStepContentForm.ClaimIntentStepContentFormField]) async {
        do {
            let inputFields: [FieldValue?] = fields.compactMap { field in
                switch field.type {
                case .date:
                    let fieldDate = dates.first(where: { $0.id == field.id })?.value ?? Date()
                    return FieldValue(id: field.id, values: [fieldDate.localDateString])
                case .number:
                    let price = selectedPrice
                    return FieldValue(id: field.id, values: [price])
                case .singleSelect:
                    let fieldValue = selectedValue.first(where: { $0.fieldId == field.id })?.value ?? ""
                    return FieldValue(id: field.id, values: [fieldValue])
                case .binary:
                    let fieldBinary = binaryValues.first(where: { $0.id == field.id })?.value ?? ""
                    return FieldValue(id: field.id, values: [fieldBinary])
                default:
                    return FieldValue(id: field.id, values: [])
                }
            }

            if let data = try await service.claimIntentSubmitForm(
                fields: inputFields.compactMap { $0 },
                stepId: currentStep?.id ?? ""
            ) {
                if let lastStep = allSteps.last {
                    let updatedStep: SubmitChatStepModel = .init(
                        step: lastStep.step,
                        sender: lastStep.sender,
                        isLoading: lastStep.isLoading,
                        isEnabled: false
                    )
                    allSteps.removeLast()
                    allSteps.append(updatedStep)
                }
                showNextStep(for: data.currentStep)
            }
        } catch {
            print("Error: couldn't submit form")
            withAnimation {
                self.viewState = .error(errorMessage: error.localizedDescription)
            }
        }
    }

    func showNextStep(for step: ClaimIntentStep) {
        withAnimation {
            currentStep = step
            allSteps.append(.init(step: step, sender: .hedvig, isLoading: false))
            switch step.content {
            case let .audioRecording(model):
                displayAudio(model)
            case let .form(model):
                displayForm(model)
            case let .fileUpload(model):
                displayFile(model)
            case let .task(model):
                displayTask(model)
            default:
                break
            }
        }
    }

    func submitSummary() async {
        do {
            if let data = try await service.claimIntentSubmitSummary(stepId: currentStep?.id ?? "") {
                allSteps.append(.init(step: data.currentStep, sender: .hedvig, isLoading: false))
                currentStep = data.currentStep
            }
        } catch {
            print("Failed sending summary:", error)
            withAnimation {
                self.viewState = .error(errorMessage: error.localizedDescription)
            }
        }
    }
}

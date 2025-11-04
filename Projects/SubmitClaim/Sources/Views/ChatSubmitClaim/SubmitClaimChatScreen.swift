import ChangeTier
import SwiftUI
import hCore
import hCoreUI

public struct SubmitClaimChatScreen: View {
    @StateObject var viewModel = SubmitClaimChatViewModel()
    @StateObject var chatInputViewModel = SubmitClaimChatInputViewModel()

    public init() {}

    public var body: some View {
        hForm {
            VStack(spacing: .padding16) {
                ForEach(viewModel.allSteps, id: \.step.id) { step in
                    HStack {
                        spacing(step.sender == .member)
                        VStack(alignment: .leading, spacing: 0) {
                            SubmitClaimChatMesageView(step: step, viewModel: viewModel)
                            switch step.step.content {
                            case .summary:
                                EmptyView()
                            default:
                                senderStamp(step: step)
                            }
                        }
                        spacing(step.sender == .hedvig)
                    }
                }
            }
            .padding(.horizontal, .padding16)
        }
        .hFormAttachToBottom {
            SubmitClaimChatInputView(
                viewModel: chatInputViewModel,
                placeHolder: viewModel.currentStep?.text ?? L10n.chatInputPlaceholder
            )
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
    }

    private var loadingView: some View {
        HStack {
            DotsActivityIndicator(.standard)
        }
        .frame(maxWidth: .infinity, maxHeight: 40, alignment: .leading)
        .padding(.horizontal, .padding16)
        .background(hBackgroundColor.primary.opacity(0.01))
        .edgesIgnoringSafeArea(.top)
        .useDarkColor
        .transition(.opacity.combined(with: .opacity).animation(.easeInOut(duration: 0.2)))
    }

    @ViewBuilder
    func spacing(_ addSpacing: Bool) -> some View {
        if addSpacing {
            Spacer()
        }
    }

    @ViewBuilder
    func senderStamp(step: SubmitChatStepModel) -> some View {
        if step.isLoading {
            loadingView
        } else if step.sender == .hedvig {
            HStack {
                Circle()
                    .frame(width: 16)
                    .foregroundColor(hSignalColor.Green.element)
                hText("Hedvig AI Assistent", style: .label)
                    .foregroundColor(hTextColor.Opaque.secondary)
            }
            .padding(.leading, .padding16)
        }
    }
}

extension SubmitClaimChatScreen: TrackingViewNameProtocol {
    public var nameForTracking: String {
        ""
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    return SubmitClaimChatScreen()
}

struct SubmitChatStepModel {
    let step: ClaimIntentStep
    let sender: SubmitClaimChatMesageSender
    var isLoading: Bool
}

struct SingleItemModel: Equatable, Identifiable {
    static func == (lhs: SingleItemModel, rhs: SingleItemModel) -> Bool {
        lhs.id == rhs.id
    }

    let id = UUID()
    let values: [SingleSelectValue]
}

@MainActor
public class SubmitClaimChatViewModel: ObservableObject {
    @Published var isDatePickerPresented: DatePickerViewModel?
    @Published var isSelectItemPresented: SingleItemModel?
    @Published var date: Date = .init()
    @Published var currentStep: ClaimIntentStep?
    @Published var allSteps: [SubmitChatStepModel] = []
    @Published var intentId: String?
    @Published var audioRecordingUrl: URL?

    @Published var hasSubmittedClaim: Bool = false
    var hasEnteredFormInput: Bool = false
    var hasSelectedDate: Bool = false
    var purchasePrice: String = ""
    var selectedValue: String = ""
    @Published var binaryValue: String = ""

    var form: Bool = false

    private let service = ClaimIntentService()

    init() {
        Task {
            await startClaim()
        }
    }

    func startClaim() async {
        do {
            let data = try await service.startClaimIntent()
            withAnimation {
                currentStep = data.currentStep
                intentId = data.id
                if let currentStep {
                    allSteps.append(.init(step: currentStep, sender: .hedvig, isLoading: false))
                    switch currentStep.content {
                    case let .audioRecording(model):
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
                    default:
                        break
                    }
                }
            }
        } catch {
            print("fail")
        }
    }

    @MainActor func getNextStep() async -> ClaimIntentStep {
        do {
            let data = try await service.getNextStep(claimIntentId: intentId ?? "")

            switch data.content {
            case .task(let model):
                if model.isCompleted {
                    currentStep = data
                    allSteps.removeLast()
                    if let currentStep {
                        allSteps.append(.init(step: currentStep, sender: .hedvig, isLoading: false))
                    }
                }
            default: break
            }

            return data
        } catch {
            print("fail")
        }
        return .init(content: .summary(model: .init(audioRecordings: [], fileUploads: [], items: [])), id: "", text: "")
    }

    func sendAudioReferenceToBackend(translatedText: String, url: String?, freeText: String?) async {
        do {
            let data = try await service.claimIntentSubmitAudio(
                reference: url,
                freeText: freeText,
                stepId: currentStep?.id ?? ""
            )
            withAnimation {
                switch data.currentStep.content {
                case let .task(model):
                    allSteps.append(.init(step: data.currentStep, sender: .hedvig, isLoading: !model.isCompleted))
                    currentStep = data.currentStep
                default:
                    allSteps.append(.init(step: data.currentStep, sender: .hedvig, isLoading: false))
                    currentStep = data.currentStep
                }

                Task {
                    await checkTaskRec()
                }
            }
        } catch {
            allSteps.removeLast()
        }
    }

    func checkTaskRec() async {
        let nextStep = await getNextStep()
        switch nextStep.content {
        case let .task(model):
            if model.isCompleted {
                allSteps.removeLast()
                allSteps.append(.init(step: nextStep, sender: .hedvig, isLoading: false))
                currentStep = nextStep

                await submitTask()
            } else {
                allSteps.removeLast()
                allSteps.append(.init(step: nextStep, sender: .hedvig, isLoading: true))
                currentStep = nextStep
                await checkTaskRec()
            }
        default: break
        }
    }

    func submitTask() async {
        do {
            let data = try await service.claimIntentSubmitTask(stepId: currentStep?.id ?? "")

            withAnimation {
                allSteps.append(.init(step: data.currentStep, sender: .hedvig, isLoading: false))
                currentStep = data.currentStep

                switch data.currentStep.content {
                case let .form(model):
                    let userStep: ClaimIntentStep = .init(
                        content: .form(model: model),
                        id: "userForm",
                        text: data.currentStep.text
                    )
                    allSteps.append(.init(step: userStep, sender: .member, isLoading: false))
                default:
                    break
                }
            }
        } catch {
            print("Failed sending task completed:", error)
        }
    }

    func submitForm(fields: [ClaimIntentStepContentForm.ClaimIntentStepContentFormField]) async {
        do {
            let inputFields: [FieldValue?] = fields.compactMap { field in
                switch field.type {
                case .date:
                    return FieldValue(id: field.id, values: [date.localDateString])
                case .number:
                    return FieldValue(id: field.id, values: [purchasePrice])
                case .singleSelect:
                    return FieldValue(id: field.id, values: [selectedValue])
                case .binary:
                    return FieldValue(id: field.id, values: [binaryValue])
                default:
                    return FieldValue(id: field.id, values: [])
                }
            }

            let data = try await service.claimIntentSubmitForm(
                fields: inputFields.compactMap { $0 },
                stepId: currentStep?.id ?? ""
            )
            withAnimation {
                hasEnteredFormInput = true
                allSteps.append(.init(step: data.currentStep, sender: .hedvig, isLoading: false))
                currentStep = data.currentStep
            }
        } catch {
            print("Error: couldn't submit form")
        }
    }

    func submitSummary() async {
        do {
            let data = try await service.claimIntentSubmitSummary(stepId: currentStep?.id ?? "")
            withAnimation {
                hasSubmittedClaim = true
                allSteps.append(.init(step: data.currentStep, sender: .hedvig, isLoading: false))
            }
        } catch {
            print("Failed sending summary:", error)
        }
    }
}

enum SubmitClaimChatMesageSender {
    case hedvig
    case member
}

enum SubmitClaimChatMesageType: Equatable, Hashable {
    case text(message: String)
    case audio
    case date
}

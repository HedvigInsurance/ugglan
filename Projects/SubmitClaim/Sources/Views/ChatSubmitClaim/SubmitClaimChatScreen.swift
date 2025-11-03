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
        //        .onChange(of: viewModel.hasSelectedDate) { _ in
        //            Task {
        //                await viewModel.submitForm(fields: [])
        //            }
        //        }
        .detent(
            item: $viewModel.isDatePickerPresented,
            transitionType: .detent(style: [.height])
        ) { datePickerVm in
            DatePickerView(vm: datePickerVm)
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

@MainActor
public class SubmitClaimChatViewModel: ObservableObject {
    @Published var isDatePickerPresented: DatePickerViewModel?
    @Published var date: Date = .init()
    @Published var currentStep: ClaimIntentStep?
    @Published var allSteps: [SubmitChatStepModel] = []
    @Published var intentId: String?
    @Published var audioRecordingUrl: URL?

    var hasSelectedDate: Bool = false
    var purchasePrice: String = ""

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
                    try? await Task.sleep(nanoseconds: 5_000_000_000)
                    let nextStep = await getNextStep()
                    switch nextStep.content {
                    case let .task(model):
                        if model.isCompleted {
                            allSteps.removeLast()
                            allSteps.append(.init(step: nextStep, sender: .hedvig, isLoading: false))
                            currentStep = nextStep

                            await submitTask()
                        }
                    default: break
                    }
                }
            }
        } catch {
            allSteps.removeLast()
        }
    }

    func submitTask() async {
        do {
            let data = try await service.claimIntentSubmitTask(stepId: currentStep?.id ?? "")

            withAnimation {
                allSteps.append(.init(step: data.currentStep, sender: .hedvig, isLoading: false))
            }
        } catch {
            //            print("Failed sending task completed:", error)

            let mockFormStep = ClaimIntentStep(
                content: .form(
                    model: .init(fields: [
                        .init(
                            defaultValue: "",
                            id: "fieldId1",
                            isRequired: true,
                            maxValue: "2026-12-01",
                            minValue: Date().localDateString,
                            options: [],
                            suffix: nil,
                            title: "Purchase date",
                            type: .date
                        ),
                        .init(
                            defaultValue: "",
                            id: "fieldId2",
                            isRequired: true,
                            maxValue: nil,
                            minValue: nil,
                            options: [],
                            suffix: nil,
                            title: "Purchace price",
                            type: .number
                        ),
                        .init(
                            defaultValue: "",
                            id: "fieldId3",
                            isRequired: true,
                            maxValue: nil,
                            minValue: nil,
                            options: [
                                .init(title: "HEMKOP", value: "Hemköp"),
                                .init(title: "ICA", value: "ICA"),
                            ],
                            suffix: nil,
                            title: "Store",
                            type: .singleSelect
                        ),
                    ]
                    )
                ),
                id: "formId",
                text: "Please tell us more about this avocado"
            )

            allSteps.append(.init(step: mockFormStep, sender: .hedvig, isLoading: false))

            let mockUserDataStep = ClaimIntentStep(
                content: .form(
                    model: .init(fields: [
                        .init(
                            defaultValue: "",
                            id: "fieldId1",
                            isRequired: true,
                            maxValue: "2026-12-01",
                            minValue: Date().localDateString,
                            options: [],
                            suffix: nil,
                            title: "Purchase date",
                            type: .date
                        ),
                        .init(
                            defaultValue: "",
                            id: "fieldId2",
                            isRequired: true,
                            maxValue: nil,
                            minValue: nil,
                            options: [],
                            suffix: nil,
                            title: "Purchace price",
                            type: .number
                        ),
                        .init(
                            defaultValue: "",
                            id: "fieldId3",
                            isRequired: true,
                            maxValue: nil,
                            minValue: nil,
                            options: [
                                .init(title: "HEMKOP", value: "Hemköp"),
                                .init(title: "ICA", value: "ICA"),
                            ],
                            suffix: nil,
                            title: "Store",
                            type: .singleSelect
                        ),
                    ]
                    )
                ),
                id: "formIdUser",
                text: "Please tell us more about this avocado"
            )

            allSteps.append(.init(step: mockUserDataStep, sender: .member, isLoading: false))

        }
    }

    func submitForm(fields: [ClaimIntentStepContentForm.ClaimIntentStepContentFormField]) async {
        withAnimation {
            //            let userStep: SubmitChatStepModel = .init(
            //                step: .init(content: .text, id: UUID().uuidString, text: date.displayDateDDMMMYYYYFormat),
            //                sender: .member,
            //                isLoading: false
            //            )
            //            allSteps.append(userStep)
            //
            //            let loadingStep: SubmitChatStepModel = .init(
            //                step: .init(content: .form(model: .init(fields: [])), id: "loadingId2", text: ""),
            //                sender: .hedvig,
            //                isLoading: true
            //            )
            //            allSteps.append(loadingStep)
        }
        do {
            let data = try await service.claimIntentSubmitForm(fields: fields, stepId: currentStep?.id ?? "")
            withAnimation {
                //                allSteps.removeLast()
                allSteps.append(.init(step: data.currentStep, sender: .hedvig, isLoading: false))
            }
        } catch {
            //            print("Failed sending task completed:", error)

            let mockCurrentStep = ClaimIntentStep(
                content: .summary(
                    model: .init(
                        audioRecordings: [],
                        fileUploads: [],
                        items: [
                            .init(title: "Type of claim", value: "bike theft"),
                            .init(title: "Date of occurrence", value: "16 okt 2025"),
                        ]
                    )
                ),
                id: "summaryId",
                text: ""
            )

            try? await Task.sleep(nanoseconds: 3_000_000_000)
            //            allSteps.removeLast()
            allSteps.append(.init(step: mockCurrentStep, sender: .hedvig, isLoading: false))
        }
    }

    func submitSummary(stepId: String) async {
        withAnimation {
            let userStep: SubmitChatStepModel = .init(
                step: .init(content: .text, id: UUID().uuidString, text: ""),
                sender: .member,
                isLoading: false
            )
            allSteps.append(userStep)

            let loadingStep: SubmitChatStepModel = .init(
                step: .init(
                    content: .summary(model: .init(audioRecordings: [], fileUploads: [], items: [])),
                    id: "loadingId3",
                    text: ""
                ),
                sender: .hedvig,
                isLoading: true
            )
            allSteps.append(loadingStep)
        }
        do {
            let data = try await service.claimIntentSubmitSummary(stepId: stepId)
            withAnimation {
                allSteps.removeLast()
                allSteps.append(.init(step: data.currentStep, sender: .hedvig, isLoading: false))
            }
        } catch {
            //            print("Failed sending task completed:", error)
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

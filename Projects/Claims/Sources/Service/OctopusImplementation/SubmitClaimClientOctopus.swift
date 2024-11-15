import Combine
import Foundation
import PresentableStore
import hCore
import hGraphQL

@MainActor
public class SubmitClaimClientOctopus: SubmitClaimClient {
    public init() {}
    @PresentableStore var store: SubmitClaimStore

    public func startClaim(entrypointId: String?, entrypointOptionId: String?) async throws -> SubmitClaimStepResponse {
        let startInput = OctopusGraphQL.FlowClaimStartInput(
            entrypointId: GraphQLNullable(optionalValue: entrypointId),
            entrypointOptionId: GraphQLNullable(optionalValue: entrypointOptionId),
            supportedSteps: GraphQLNullable(optionalValue: supportedSteps())
        )
        let mutation = OctopusGraphQL.FlowClaimStartMutation(input: startInput, context: GraphQLNullable.none)
        return try await mutation.execute(\.flowClaimStart.fragments.flowClaimFragment.currentStep)
    }

    public func updateContact(phoneNumber: String, context: String) async throws -> SubmitClaimStepResponse {
        let phoneNumberInput = OctopusGraphQL.FlowClaimPhoneNumberInput(phoneNumber: phoneNumber)
        let mutation = OctopusGraphQL.FlowClaimPhoneNumberNextMutation(input: phoneNumberInput, context: context)
        return try await mutation.execute(\.flowClaimPhoneNumberNext.fragments.flowClaimFragment.currentStep)
    }

    public func dateOfOccurrenceAndLocationRequest(context: String) async throws -> SubmitClaimStepResponse {
        if let dateOfOccurrenceStep = store.state.dateOfOccurenceStep, let locationStep = store.state.locationStep {
            let location = locationStep.getSelectedOption()?.value
            let date = dateOfOccurrenceStep.dateOfOccurence

            let dateAndLocationInput = OctopusGraphQL.FlowClaimDateOfOccurrencePlusLocationInput(
                dateOfOccurrence: GraphQLNullable(optionalValue: date),
                location: GraphQLNullable(optionalValue: location)
            )
            let mutation = OctopusGraphQL.FlowClaimDateOfOccurrencePlusLocationNextMutation(
                input: dateAndLocationInput,
                context: context
            )

            return try await mutation.execute(
                \.flowClaimDateOfOccurrencePlusLocationNext.fragments.flowClaimFragment.currentStep
            )
        } else if let dateOfOccurrenceStep = store.state.dateOfOccurenceStep {
            let dateString = dateOfOccurrenceStep.dateOfOccurence
            let dateOfOccurrenceInput = OctopusGraphQL.FlowClaimDateOfOccurrenceInput(
                dateOfOccurrence: GraphQLNullable(optionalValue: dateString)
            )
            let mutation = OctopusGraphQL.FlowClaimDateOfOccurrenceNextMutation(
                input: dateOfOccurrenceInput,
                context: context
            )
            return try await mutation.execute(\.flowClaimDateOfOccurrenceNext.fragments.flowClaimFragment.currentStep)

        } else if let locationStep = store.state.locationStep {
            let locationInput = OctopusGraphQL.FlowClaimLocationInput(
                location: GraphQLNullable(optionalValue: locationStep.location)
            )
            let mutation = OctopusGraphQL.FlowClaimLocationNextMutation(
                input: locationInput,
                context: context
            )
            return try await mutation.execute(\.flowClaimLocationNext.fragments.flowClaimFragment.currentStep)
        }
        throw SubmitClaimError.error(message: L10n.General.errorBody)
    }

    public func submitAudioRecording(
        type: SubmitAudioRecordingType,
        fileUploaderClient: FileUploaderClient,
        context: String
    ) async throws -> SubmitClaimStepResponse {
        switch type {
        case .audio(let audioURL):
            do {
                if let url = store.state.audioRecordingStep?.audioContent?.audioUrl {
                    let audioInput = OctopusGraphQL.FlowClaimAudioRecordingInput(
                        audioUrl: GraphQLNullable(optionalValue: url),
                        freeText: .none
                    )
                    let mutation = OctopusGraphQL.FlowClaimAudioRecordingNextMutation(
                        input: audioInput,
                        context: context
                    )

                    return try await mutation.execute(
                        \.flowClaimAudioRecordingNext.fragments.flowClaimFragment.currentStep
                    )
                } else {
                    let data = try Data(contentsOf: audioURL)
                    let name = audioURL.lastPathComponent
                    let uploadFile = UploadFile(data: data, name: name, mimeType: "audio/x-m4a")

                    let fileUploaderData = try await fileUploaderClient.upload(
                        flowId: store.state.currentClaimId,
                        file: uploadFile
                    )

                    let mutation = OctopusGraphQL.FlowClaimAudioRecordingNextMutation(
                        input: .init(
                            audioUrl: GraphQLNullable(optionalValue: fileUploaderData.audioUrl),
                            freeText: .none
                        ),
                        context: context
                    )
                    return try await mutation.execute(
                        \.flowClaimAudioRecordingNext.fragments.flowClaimFragment.currentStep
                    )
                }
            } catch {
                throw SubmitClaimError.error(message: error.localizedDescription)
            }
        case let .text(text):
            let audioInput = OctopusGraphQL.FlowClaimAudioRecordingInput(
                audioUrl: .none,
                freeText: GraphQLNullable(optionalValue: text)
            )
            let mutation = OctopusGraphQL.FlowClaimAudioRecordingNextMutation(
                input: audioInput,
                context: context
            )
            return try await mutation.execute(\.flowClaimAudioRecordingNext.fragments.flowClaimFragment.currentStep)
        }
    }

    public func singleItemRequest(purchasePrice: Double?, context: String) async throws -> SubmitClaimStepResponse {
        let singleItemInput = store.state.singleItemStep!.returnSingleItemInfo(purchasePrice: purchasePrice)
        let mutation = OctopusGraphQL.FlowClaimSingleItemNextMutation(
            input: singleItemInput,
            context: context
        )
        return try await mutation.execute(\.flowClaimSingleItemNext.fragments.flowClaimFragment.currentStep)
    }

    public func summaryRequest(context: String) async throws -> SubmitClaimStepResponse {
        let summaryInput = OctopusGraphQL.FlowClaimSummaryInput()
        let mutation = OctopusGraphQL.FlowClaimSummaryNextMutation(
            input: summaryInput,
            context: context
        )
        return try await mutation.execute(\.flowClaimSummaryNext.fragments.flowClaimFragment.currentStep)
    }

    public func singleItemCheckoutRequest(context: String) async throws -> SubmitClaimStepResponse {
        if let claimSingleItemCheckoutInput = store.state.singleItemCheckoutStep?.returnSingleItemCheckoutInfo() {
            let mutation = OctopusGraphQL.FlowClaimSingleItemCheckoutNextMutation(
                input: claimSingleItemCheckoutInput,
                context: context
            )
            return try await mutation.execute(\.flowClaimSingleItemCheckoutNext.fragments.flowClaimFragment.currentStep)
        } else {
            throw SubmitClaimError.error(message: L10n.General.errorBody)
        }
    }

    public func contractSelectRequest(contractId: String, context: String) async throws -> SubmitClaimStepResponse {
        let contractSelectInput = OctopusGraphQL.FlowClaimContractSelectInput(
            contractId: GraphQLNullable(optionalValue: contractId)
        )
        let mutation = OctopusGraphQL.FlowClaimContractSelectNextMutation(
            input: contractSelectInput,
            context: context
        )
        return try await mutation.execute(\.flowClaimContractSelectNext.fragments.flowClaimFragment.currentStep)
    }

    public func emergencyConfirmRequest(isEmergency: Bool, context: String) async throws -> SubmitClaimStepResponse {
        let confirmEmergencyInput = OctopusGraphQL.FlowClaimConfirmEmergencyInput(confirmEmergency: isEmergency)
        let mutation = OctopusGraphQL.FlowClaimConfirmEmergencyNextMutation(
            input: confirmEmergencyInput,
            context: GraphQLNullable(optionalValue: context)
        )
        return try await mutation.execute(\.flowClaimConfirmEmergencyNext.fragments.flowClaimFragment.currentStep)
    }

    public func submitFileUpload(ids: [String], context: String) async throws -> SubmitClaimStepResponse {
        let input = OctopusGraphQL.FlowClaimFileUploadInput(fileIds: ids)
        let mutation = OctopusGraphQL.FlowClaimFileUploadNextMutation(input: input, context: context)
        return try await mutation.execute(\.flowClaimFileUploadNext.fragments.flowClaimFragment.currentStep)
    }

    private func supportedSteps() -> [OctopusGraphQL.ID] {
        return [
            OctopusGraphQL.Objects.FlowClaimDateOfOccurrenceStep.typename,
            OctopusGraphQL.Objects.FlowClaimDateOfOccurrencePlusLocationStep.typename,
            OctopusGraphQL.Objects.FlowClaimLocationStep.typename,
            OctopusGraphQL.Objects.FlowClaimAudioRecordingStep.typename,
            OctopusGraphQL.Objects.FlowClaimContractSelectStep.typename,
            OctopusGraphQL.Objects.FlowClaimFileUploadStep.typename,
            OctopusGraphQL.Objects.FlowClaimPhoneNumberStep.typename,
            OctopusGraphQL.Objects.FlowClaimSummaryStep.typename,
            OctopusGraphQL.Objects.FlowClaimSingleItemStep.typename,
            OctopusGraphQL.Objects.FlowClaimConfirmEmergencyStep.typename,
            OctopusGraphQL.Objects.FlowClaimSingleItemCheckoutStep.typename,
            OctopusGraphQL.Objects.FlowClaimSuccessStep.typename,
            OctopusGraphQL.Objects.FlowClaimDeflectEirStep.typename,
            OctopusGraphQL.Objects.FlowClaimDeflectEmergencyStep.typename,
            OctopusGraphQL.Objects.FlowClaimDeflectGlassDamageStep.typename,
            OctopusGraphQL.Objects.FlowClaimDeflectPestsStep.typename,
            OctopusGraphQL.Objects.FlowClaimDeflectTowingStep.typename,
            OctopusGraphQL.Objects.FlowClaimFailedStep.typename,
        ]
    }
}

@MainActor
extension GraphQLMutation {
    fileprivate func execute<ClaimStep: Into>(
        _ keyPath: KeyPath<Self.Data, ClaimStep>
    ) async throws -> SubmitClaimStepResponse
    where
        ClaimStep.To == SubmitClaimsAction, Self: ClaimStepLoadingType, Self.Data: ClaimStepContext,
        Self.Data: ClaimStepProgress, Self.Data: ClaimStepId
    {
        let octopus: hOctopus = Dependencies.shared.resolve()
        do {
            let data = try await octopus.client.perform(mutation: self)
            let claimId = data.getStepId()
            let context = data.getContext()
            let progress: Float? = {
                if let clearedSteps = data.getProgress().clearedSteps,
                    let totalSteps = data.getProgress().totalSteps
                {
                    if clearedSteps != 0 {
                        let progressValue = Float(Float(clearedSteps) / Float(totalSteps)) * 0.7 + 0.3
                        return progressValue
                    } else {
                        return 0.3
                    }
                } else {
                    return nil
                }
            }()
            let results = Task {
                await data[keyPath: keyPath].into()
            }
            let action = await results.value
            return .init(claimId: claimId, context: context, progress: progress, action: action)
        } catch _ {
            throw SubmitClaimError.error(message: L10n.General.errorBody)
        }
    }
}

enum SubmitClaimError: Error {
    case error(message: String)
}

extension SubmitClaimError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case let .error(message): return message
        }
    }
}

private protocol Into<To> where To: Sendable {
    associatedtype To
    func into() async -> To
}

extension OctopusGraphQL.FlowClaimFragment.CurrentStep: Into {
    fileprivate func into() async -> SubmitClaimsAction {
        if let step = self.asFlowClaimPhoneNumberStep?.fragments.flowClaimPhoneNumberStepFragment {
            return .stepModelAction(action: .setPhoneNumber(model: .init(with: step)))
        } else if let step = self.asFlowClaimAudioRecordingStep?.fragments.flowClaimAudioRecordingStepFragment {
            return .stepModelAction(action: .setAudioStep(model: .init(with: step)))
        } else if let step = self.asFlowClaimSingleItemStep?.fragments.flowClaimSingleItemStepFragment {
            return await .stepModelAction(action: .setSingleItem(model: .init(with: step)))
        } else if let step = self.asFlowClaimSingleItemCheckoutStep?.fragments.flowClaimSingleItemCheckoutStepFragment {
            return await .stepModelAction(action: .setSingleItemCheckoutStep(model: .init(with: step)))
        } else if let step = self.asFlowClaimLocationStep?.fragments.flowClaimLocationStepFragment {
            return .stepModelAction(action: .setLocation(model: .init(with: step)))
        } else if let step = self.asFlowClaimDateOfOccurrenceStep?.fragments.flowClaimDateOfOccurrenceStepFragment {
            return .stepModelAction(action: .setDateOfOccurence(model: .init(with: step)))
        } else if let step = self.asFlowClaimSummaryStep?.fragments.flowClaimSummaryStepFragment {
            let summaryStep = FlowClaimSummaryStepModel(with: step)
            let singleItemStepModel: FlowClamSingleItemStepModel? = await {
                if let singleItemStep = step.singleItemStep?.fragments.flowClaimSingleItemStepFragment {
                    return await .init(with: singleItemStep)
                }
                return nil
            }()
            return .stepModelAction(
                action: .setSummaryStep(
                    model: .init(
                        summaryStep: summaryStep,
                        singleItemStepModel: singleItemStepModel,
                        dateOfOccurenceModel: .init(
                            with: step.dateOfOccurrenceStep.fragments.flowClaimDateOfOccurrenceStepFragment
                        ),
                        locationModel: .init(with: step.locationStep.fragments.flowClaimLocationStepFragment),
                        audioRecordingModel: .init(
                            with: step.audioRecordingStep?.fragments.flowClaimAudioRecordingStepFragment
                        ),
                        fileUploadModel: .init(with: step.fileUploadStep?.fragments.flowClaimFileUploadStepFragment)
                    )
                )
            )
        } else if let step = self.asFlowClaimDateOfOccurrencePlusLocationStep?.fragments
            .flowClaimDateOfOccurrencePlusLocationStepFragment
        {
            return .stepModelAction(
                action: .setDateOfOccurrencePlusLocation(
                    model: .init(
                        dateOfOccurencePlusLocationModel: .init(with: step),
                        dateOfOccurenceModel: .init(
                            with: step.dateOfOccurrenceStep.fragments.flowClaimDateOfOccurrenceStepFragment
                        ),
                        locationModel: .init(with: step.locationStep.fragments.flowClaimLocationStepFragment)
                    )
                )
            )
        } else if let step = self.asFlowClaimFailedStep?.fragments.flowClaimFailedStepFragment {
            return .stepModelAction(action: .setFailedStep(model: .init(with: step)))
        } else if let step = self.asFlowClaimSuccessStep?.fragments.flowClaimSuccessStepFragment {
            return .stepModelAction(action: .setSuccessStep(model: .init(with: step)))
        } else if let step = self.asFlowClaimContractSelectStep?.fragments.flowClaimContractSelectStepFragment {
            return .stepModelAction(action: .setContractSelectStep(model: .init(with: step)))
        } else if let step = self.asFlowClaimDeflectEmergencyStep?.fragments.flowClaimDeflectEmergencyStepFragment {
            return .stepModelAction(action: .setDeflectModel(model: .init(with: step)))
        } else if let step = self.asFlowClaimConfirmEmergencyStep?.fragments.flowClaimConfirmEmergencyStepFragment {
            return .stepModelAction(action: .setConfirmDeflectEmergencyStepModel(model: .init(with: step)))
        } else if let step = self.asFlowClaimDeflectPestsStep?.fragments.flowClaimDeflectPestsStepFragment {
            return .stepModelAction(action: .setDeflectModel(model: .init(with: step)))
        } else if let step = self.asFlowClaimDeflectGlassDamageStep?.fragments.flowClaimDeflectGlassDamageStepFragment {
            return .stepModelAction(action: .setDeflectModel(model: .init(with: step)))
        } else if let step = self.asFlowClaimDeflectTowingStep?.fragments.flowClaimDeflectTowingStepFragment {
            return .stepModelAction(action: .setDeflectModel(model: .init(with: step)))
        } else if let step = self.asFlowClaimDeflectEirStep?.fragments.flowClaimDeflectEirStepFragment {
            return .stepModelAction(action: .setDeflectModel(model: .init(with: step)))
        } else if let step = self.asFlowClaimFileUploadStep?.fragments.flowClaimFileUploadStepFragment {
            return .stepModelAction(action: .setFileUploadStep(model: .init(with: step)))
        } else {
            return .navigationAction(action: .openUpdateAppScreen)
        }
    }
}

private protocol ClaimStepId {
    func getStepId() -> String
}

private protocol ClaimStepContext {
    func getContext() -> String
}

private protocol ClaimStepProgress {
    func getProgress() -> (clearedSteps: Int?, totalSteps: Int?)
}

extension OctopusGraphQL.FlowClaimStartMutation.Data: ClaimStepId, ClaimStepContext, ClaimStepProgress {
    func getContext() -> String {
        return self.flowClaimStart.context
    }
    func getProgress() -> (clearedSteps: Int?, totalSteps: Int?) {
        return (
            clearedSteps: self.flowClaimStart.progress?.clearedSteps ?? 0,
            totalSteps: self.flowClaimStart.progress?.totalSteps ?? 0
        )
    }
    func getStepId() -> String {
        return self.flowClaimStart.id
    }
}

extension OctopusGraphQL.FlowClaimDateOfOccurrencePlusLocationNextMutation.Data: ClaimStepId, ClaimStepContext,
    ClaimStepProgress
{
    func getContext() -> String {
        return self.flowClaimDateOfOccurrencePlusLocationNext.context
    }
    func getStepId() -> String {
        return self.flowClaimDateOfOccurrencePlusLocationNext.id
    }
    func getProgress() -> (clearedSteps: Int?, totalSteps: Int?) {
        return (
            clearedSteps: self.flowClaimDateOfOccurrencePlusLocationNext.progress?.clearedSteps ?? 0,
            totalSteps: self.flowClaimDateOfOccurrencePlusLocationNext.progress?.totalSteps ?? 0
        )
    }
}

extension OctopusGraphQL.FlowClaimContractSelectNextMutation.Data: ClaimStepId, ClaimStepContext, ClaimStepProgress {
    func getContext() -> String {
        return self.flowClaimContractSelectNext.context
    }
    func getStepId() -> String {
        return self.flowClaimContractSelectNext.id
    }
    func getProgress() -> (clearedSteps: Int?, totalSteps: Int?) {
        return (
            clearedSteps: self.flowClaimContractSelectNext.progress?.clearedSteps ?? 0,
            totalSteps: self.flowClaimContractSelectNext.progress?.totalSteps ?? 0
        )
    }
}

extension OctopusGraphQL.FlowClaimConfirmEmergencyNextMutation.Data: ClaimStepId, ClaimStepContext, ClaimStepProgress {
    func getContext() -> String {
        return self.flowClaimConfirmEmergencyNext.context
    }
    func getStepId() -> String {
        return self.flowClaimConfirmEmergencyNext.id
    }
    func getProgress() -> (clearedSteps: Int?, totalSteps: Int?) {
        return (
            clearedSteps: self.flowClaimConfirmEmergencyNext.progress?.clearedSteps ?? 0,
            totalSteps: self.flowClaimConfirmEmergencyNext.progress?.totalSteps ?? 0
        )
    }
}

extension OctopusGraphQL.FlowClaimAudioRecordingNextMutation.Data: ClaimStepId, ClaimStepContext, ClaimStepProgress {
    func getContext() -> String {
        return self.flowClaimAudioRecordingNext.context
    }
    func getStepId() -> String {
        return self.flowClaimAudioRecordingNext.id
    }
    func getProgress() -> (clearedSteps: Int?, totalSteps: Int?) {
        return (
            clearedSteps: self.flowClaimAudioRecordingNext.progress?.clearedSteps ?? 0,
            totalSteps: self.flowClaimAudioRecordingNext.progress?.totalSteps ?? 0
        )
    }
}

extension OctopusGraphQL.FlowClaimPhoneNumberNextMutation.Data: ClaimStepId, ClaimStepContext, ClaimStepProgress {
    func getContext() -> String {
        return self.flowClaimPhoneNumberNext.context
    }
    func getStepId() -> String {
        return self.flowClaimPhoneNumberNext.id
    }
    func getProgress() -> (clearedSteps: Int?, totalSteps: Int?) {
        return (
            clearedSteps: self.flowClaimPhoneNumberNext.progress?.clearedSteps ?? 0,
            totalSteps: self.flowClaimPhoneNumberNext.progress?.totalSteps ?? 0
        )
    }
}

extension OctopusGraphQL.FlowClaimDateOfOccurrenceNextMutation.Data: ClaimStepId, ClaimStepContext, ClaimStepProgress {
    func getContext() -> String {
        return self.flowClaimDateOfOccurrenceNext.context
    }
    func getStepId() -> String {
        return self.flowClaimDateOfOccurrenceNext.id
    }
    func getProgress() -> (clearedSteps: Int?, totalSteps: Int?) {
        return (
            clearedSteps: self.flowClaimDateOfOccurrenceNext.progress?.clearedSteps ?? 0,
            totalSteps: self.flowClaimDateOfOccurrenceNext.progress?.totalSteps ?? 0
        )
    }
}

extension OctopusGraphQL.FlowClaimLocationNextMutation.Data: ClaimStepId, ClaimStepContext, ClaimStepProgress {
    func getContext() -> String {
        return self.flowClaimLocationNext.context
    }
    func getStepId() -> String {
        return self.flowClaimLocationNext.id
    }
    func getProgress() -> (clearedSteps: Int?, totalSteps: Int?) {
        return (
            clearedSteps: self.flowClaimLocationNext.progress?.clearedSteps ?? 0,
            totalSteps: self.flowClaimLocationNext.progress?.totalSteps ?? 0
        )
    }
}

extension OctopusGraphQL.FlowClaimSingleItemNextMutation.Data: ClaimStepId, ClaimStepContext, ClaimStepProgress {
    func getContext() -> String {
        return self.flowClaimSingleItemNext.context
    }
    func getStepId() -> String {
        return self.flowClaimSingleItemNext.id
    }
    func getProgress() -> (clearedSteps: Int?, totalSteps: Int?) {
        return (
            clearedSteps: self.flowClaimSingleItemNext.progress?.clearedSteps ?? 0,
            totalSteps: self.flowClaimSingleItemNext.progress?.totalSteps ?? 0
        )
    }
}

extension OctopusGraphQL.FlowClaimSummaryNextMutation.Data: ClaimStepId, ClaimStepContext, ClaimStepProgress {
    func getContext() -> String {
        return self.flowClaimSummaryNext.context
    }
    func getStepId() -> String {
        return self.flowClaimSummaryNext.id
    }
    func getProgress() -> (clearedSteps: Int?, totalSteps: Int?) {
        return (
            clearedSteps: self.flowClaimSummaryNext.progress?.clearedSteps ?? 0,
            totalSteps: self.flowClaimSummaryNext.progress?.totalSteps ?? 0
        )
    }
}

extension OctopusGraphQL.FlowClaimSingleItemCheckoutNextMutation.Data: ClaimStepId, ClaimStepContext, ClaimStepProgress
{
    func getContext() -> String {
        return self.flowClaimSingleItemCheckoutNext.context
    }
    func getStepId() -> String {
        return self.flowClaimSingleItemCheckoutNext.id
    }
    func getProgress() -> (clearedSteps: Int?, totalSteps: Int?) {
        return (
            clearedSteps: self.flowClaimSingleItemCheckoutNext.progress?.clearedSteps ?? 0,
            totalSteps: self.flowClaimSingleItemCheckoutNext.progress?.totalSteps ?? 0
        )
    }
}

extension OctopusGraphQL.FlowClaimFileUploadNextMutation.Data: ClaimStepId, ClaimStepContext, ClaimStepProgress {
    func getContext() -> String {
        return self.flowClaimFileUploadNext.context
    }
    func getStepId() -> String {
        return self.flowClaimFileUploadNext.id
    }
    func getProgress() -> (clearedSteps: Int?, totalSteps: Int?) {
        return (
            clearedSteps: self.flowClaimFileUploadNext.progress?.clearedSteps ?? 0,
            totalSteps: self.flowClaimFileUploadNext.progress?.totalSteps ?? 0
        )
    }
}

//MARK: loading type
protocol ClaimStepLoadingType {
    func getLoadingType() -> ClaimsLoadingType
}

extension OctopusGraphQL.FlowClaimStartMutation: ClaimStepLoadingType {
    func getLoadingType() -> ClaimsLoadingType {
        return .startClaim
    }
}

extension OctopusGraphQL.FlowClaimPhoneNumberNextMutation: ClaimStepLoadingType {
    func getLoadingType() -> ClaimsLoadingType {
        return .postPhoneNumber
    }
}

extension OctopusGraphQL.FlowClaimDateOfOccurrenceNextMutation: ClaimStepLoadingType {
    func getLoadingType() -> ClaimsLoadingType {
        return .postDateOfOccurrenceAndLocation
    }
}

extension OctopusGraphQL.FlowClaimDateOfOccurrencePlusLocationNextMutation: ClaimStepLoadingType {
    func getLoadingType() -> ClaimsLoadingType {
        return .postDateOfOccurrenceAndLocation
    }
}

extension OctopusGraphQL.FlowClaimContractSelectNextMutation: ClaimStepLoadingType {
    func getLoadingType() -> ClaimsLoadingType {
        return .postContractSelect
    }
}

extension OctopusGraphQL.FlowClaimConfirmEmergencyNextMutation: ClaimStepLoadingType {
    func getLoadingType() -> ClaimsLoadingType {
        return .postConfirmEmergency
    }
}

extension OctopusGraphQL.FlowClaimLocationNextMutation: ClaimStepLoadingType {
    func getLoadingType() -> ClaimsLoadingType {
        return .postDateOfOccurrenceAndLocation
    }
}

extension OctopusGraphQL.FlowClaimAudioRecordingNextMutation: ClaimStepLoadingType {
    func getLoadingType() -> ClaimsLoadingType {
        return .postAudioRecording
    }
}

extension OctopusGraphQL.FlowClaimSingleItemNextMutation: ClaimStepLoadingType {
    func getLoadingType() -> ClaimsLoadingType {
        return .postSingleItem
    }
}

extension OctopusGraphQL.FlowClaimSingleItemCheckoutNextMutation: ClaimStepLoadingType {
    func getLoadingType() -> ClaimsLoadingType {
        return .postSingleItemCheckout
    }
}

extension OctopusGraphQL.FlowClaimFileUploadNextMutation: ClaimStepLoadingType {
    func getLoadingType() -> ClaimsLoadingType {
        return .postUploadFiles
    }
}

extension OctopusGraphQL.FlowClaimSummaryNextMutation: ClaimStepLoadingType {
    func getLoadingType() -> ClaimsLoadingType {
        return .postSummary
    }
}

extension FlowClaimSuccessStepModel {
    init(
        with data: OctopusGraphQL.FlowClaimSuccessStepFragment
    ) {
        self.id = data.id
    }
}

extension FlowClaimFailedStepModel {
    init(
        with data: OctopusGraphQL.FlowClaimFailedStepFragment
    ) {
        self.id = data.id
    }
}

extension FlowClaimDateOfOccurenceStepModel {
    init(
        with data: OctopusGraphQL.FlowClaimDateOfOccurrenceStepFragment
    ) {
        self.id = data.id
        self.dateOfOccurence = data.dateOfOccurrence
        self.maxDate = data.maxDate
    }

    @MainActor
    func getMaxDate() -> Date {
        return maxDate?.localDateToDate ?? Date()
    }
}

extension FlowClaimDateOfOccurrencePlusLocationStepModel {
    init(
        with data: OctopusGraphQL.FlowClaimDateOfOccurrencePlusLocationStepFragment
    ) {
        self.id = data.id
    }
}

extension FlowClaimLocationStepModel {
    init(
        with data: OctopusGraphQL.FlowClaimLocationStepFragment
    ) {
        self.id = data.id
        self.location = data.location
        self.options = data.options.map({ .init(with: $0) })
    }
}

extension FlowClaimAudioRecordingStepModel {
    init?(
        with data: OctopusGraphQL.FlowClaimAudioRecordingStepFragment?
    ) {
        guard let data else {
            return nil
        }
        self.id = data.id
        self.questions = data.questions
        self.audioContent = .init(with: (data.audioContent?.fragments.flowClaimAudioContentFragment))
        self.textQuestions = data.freeTextQuestions
        self.inputTextContent = data.freeText
        self.optionalAudio = data.freeTextAvailable
    }
}

extension FlowClaimPhoneNumberStepModel {
    init(
        with data: OctopusGraphQL.FlowClaimPhoneNumberStepFragment
    ) {
        self.id = data.id
        self.phoneNumber = data.phoneNumber
    }
}

extension FlowClaimContractSelectStepModel {
    init(
        with data: OctopusGraphQL.FlowClaimContractSelectStepFragment
    ) {
        self.selectedContractId = data.options.first?.id
        self.availableContractOptions = data.options.map({ .init(with: $0) })
    }
}

extension FlowClaimContractSelectOptionModel {
    init(
        with data: OctopusGraphQL.FlowClaimContractSelectStepFragment.Option
    ) {
        self.displayName = data.displayName
        self.id = data.id
    }
}

extension FlowClaimConfirmEmergencyStepModel {
    init(
        with data: OctopusGraphQL.FlowClaimConfirmEmergencyStepFragment
    ) {
        self.id = data.id
        self.text = data.text
        self.confirmEmergency = data.confirmEmergency
        self.options = data.options.map({ data in
            FlowClaimConfirmEmergencyOption(displayName: data.displayName, value: data.displayValue)
        })
    }
}

extension FlowClaimFileUploadStepModel {
    init?(
        with data: OctopusGraphQL.FlowClaimFileUploadStepFragment?
    ) {
        guard let data else {
            return nil
        }
        self.id = data.id
        self.title = data.title
        self.targetUploadUrl = data.targetUploadUrl
        self.uploads = data.uploads.compactMap({
            FlowClaimFileUploadStepFileModel(
                fileId: $0.fileId,
                signedUrl: $0.signedUrl,
                mimeType: $0.mimeType,
                name: $0.name
            )
        })
    }
}

extension FlowClaimSummaryStepModel {
    init(
        with data: OctopusGraphQL.FlowClaimSummaryStepFragment
    ) {
        self.id = data.id
        self.title = data.title
        self.shouldShowDateOfOccurence = true
        self.shouldShowLocation = true
        self.shouldShowSingleItem = data.singleItemStep != nil
    }
}

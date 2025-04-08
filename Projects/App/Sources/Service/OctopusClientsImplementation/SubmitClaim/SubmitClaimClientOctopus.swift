import Claims
import SubmitClaim
import UIKit
import hCore
import hGraphQL

class SubmitClaimClientOctopus: SubmitClaimClient {
    private let fileUploadService = FileUploaderService()
    func startClaim(entrypointId: String?, entrypointOptionId: String?) async throws -> SubmitClaimStepResponse {
        let startInput = OctopusGraphQL.FlowClaimStartInput(
            entrypointId: GraphQLNullable(optionalValue: entrypointId),
            entrypointOptionId: GraphQLNullable(optionalValue: entrypointOptionId),
            supportedSteps: GraphQLNullable(optionalValue: supportedSteps())
        )
        let mutation = OctopusGraphQL.FlowClaimStartMutation(input: startInput, context: GraphQLNullable.none)
        return try await mutation.execute(\.flowClaimStart.fragments.flowClaimFragment.currentStep)
    }

    func updateContact(
        phoneNumber: String,
        context: String,
        model: FlowClaimPhoneNumberStepModel
    ) async throws -> SubmitClaimStepResponse {
        let phoneNumberInput = OctopusGraphQL.FlowClaimPhoneNumberInput(phoneNumber: phoneNumber)
        let mutation = OctopusGraphQL.FlowClaimPhoneNumberNextMutation(input: phoneNumberInput, context: context)
        return try await mutation.execute(\.flowClaimPhoneNumberNext.fragments.flowClaimFragment.currentStep)
    }

    func dateOfOccurrenceAndLocationRequest(
        context: String,
        model: SubmitClaimStep.DateOfOccurrencePlusLocationStepModels
    ) async throws -> SubmitClaimStepResponse {
        if let dateOfOccurrenceStep = model.dateOfOccurrenceModel, let locationStep = model.locationModel {
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
        } else if let dateOfOccurrenceStep = model.dateOfOccurrenceModel {
            let dateString = dateOfOccurrenceStep.dateOfOccurence
            let dateOfOccurrenceInput = OctopusGraphQL.FlowClaimDateOfOccurrenceInput(
                dateOfOccurrence: GraphQLNullable(optionalValue: dateString)
            )
            let mutation = OctopusGraphQL.FlowClaimDateOfOccurrenceNextMutation(
                input: dateOfOccurrenceInput,
                context: context
            )
            return try await mutation.execute(\.flowClaimDateOfOccurrenceNext.fragments.flowClaimFragment.currentStep)

        } else if let locationStep = model.locationModel {
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

    func submitAudioRecording(
        type: SubmitAudioRecordingType,
        context: String,
        currentClaimId: String,
        model: FlowClaimAudioRecordingStepModel
    ) async throws -> SubmitClaimStepResponse {
        switch type {
        case .audio(let audioURL):
            do {
                if let url = model.audioContent?.audioUrl {
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

                    let fileUploaderData = try await fileUploadService.upload(
                        flowId: currentClaimId,
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

    func singleItemRequest(
        context: String,
        model: FlowClaimSingleItemStepModel
    ) async throws -> SubmitClaimStepResponse {
        let singleItemInput = model.returnSingleItemInfo(purchasePrice: model.purchasePrice)
        let mutation = OctopusGraphQL.FlowClaimSingleItemNextMutation(
            input: singleItemInput,
            context: context
        )
        return try await mutation.execute(\.flowClaimSingleItemNext.fragments.flowClaimFragment.currentStep)
    }

    func summaryRequest(
        context: String,
        model: SubmitClaimStep.SummaryStepModels
    ) async throws -> SubmitClaimStepResponse {
        let summaryInput = OctopusGraphQL.FlowClaimSummaryInput()
        let mutation = OctopusGraphQL.FlowClaimSummaryNextMutation(
            input: summaryInput,
            context: context
        )
        return try await mutation.execute(\.flowClaimSummaryNext.fragments.flowClaimFragment.currentStep)
    }

    func singleItemCheckoutRequest(
        context: String,
        model: FlowClaimSingleItemCheckoutStepModel
    ) async throws -> SubmitClaimStepResponse {
        if let claimSingleItemCheckoutInput = model.returnSingleItemCheckoutInfo() {
            let mutation = OctopusGraphQL.FlowClaimSingleItemCheckoutNextMutation(
                input: claimSingleItemCheckoutInput,
                context: context
            )
            return try await mutation.execute(\.flowClaimSingleItemCheckoutNext.fragments.flowClaimFragment.currentStep)
        } else {
            throw SubmitClaimError.error(message: L10n.General.errorBody)
        }
    }

    func contractSelectRequest(
        contractId: String,
        context: String,
        model: FlowClaimContractSelectStepModel
    ) async throws -> SubmitClaimStepResponse {
        let contractSelectInput = OctopusGraphQL.FlowClaimContractSelectInput(
            contractId: GraphQLNullable(optionalValue: contractId)
        )
        let mutation = OctopusGraphQL.FlowClaimContractSelectNextMutation(
            input: contractSelectInput,
            context: context
        )
        return try await mutation.execute(\.flowClaimContractSelectNext.fragments.flowClaimFragment.currentStep)
    }

    func emergencyConfirmRequest(isEmergency: Bool, context: String) async throws -> SubmitClaimStepResponse {
        let confirmEmergencyInput = OctopusGraphQL.FlowClaimConfirmEmergencyInput(confirmEmergency: isEmergency)
        let mutation = OctopusGraphQL.FlowClaimConfirmEmergencyNextMutation(
            input: confirmEmergencyInput,
            context: GraphQLNullable(optionalValue: context)
        )
        return try await mutation.execute(\.flowClaimConfirmEmergencyNext.fragments.flowClaimFragment.currentStep)
    }

    func submitFileUpload(
        ids: [String],
        context: String,
        model: FlowClaimFileUploadStepModel
    ) async throws -> SubmitClaimStepResponse {
        let input = OctopusGraphQL.FlowClaimFileUploadInput(fileIds: ids)
        let mutation = OctopusGraphQL.FlowClaimFileUploadNextMutation(input: input, context: context)
        return try await mutation.execute(\.flowClaimFileUploadNext.fragments.flowClaimFragment.currentStep)
    }

    func supportedSteps() -> [OctopusGraphQL.ID] {
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
            OctopusGraphQL.Objects.FlowClaimDeflectIDProtectionStep.typename,
        ]
    }
}

@MainActor
extension GraphQLMutation {
    fileprivate func execute<ClaimStep: Into>(
        _ keyPath: KeyPath<Self.Data, ClaimStep>
    ) async throws -> SubmitClaimStepResponse
    where
        ClaimStep.To == SubmitClaimStep, Self.Data: ClaimStepContext,
        Self.Data: ClaimStepProgress, Self.Data: ClaimId,
        Self.Data: NextStepId
    {
        let octopus: hOctopus = Dependencies.shared.resolve()
        do {
            let data = try await octopus.client.perform(mutation: self)
            let claimId = data.getClaimId()
            let context = data.getContext()
            let nextStepId = data.getNextStepId()
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
            let step = data[keyPath: keyPath].into()
            return .init(claimId: claimId, context: context, progress: progress, step: step, nextStepId: nextStepId)
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

@MainActor
private protocol Into<To> where To: Sendable {
    associatedtype To
    func into() -> To
}

extension OctopusGraphQL.FlowClaimFragment.CurrentStep: Into {
    func into() -> SubmitClaimStep {
        if let step = self.asFlowClaimDateOfOccurrenceStep?.fragments.flowClaimDateOfOccurrenceStepFragment {
            return .setDateOfOccurence(model: .init(with: step))
        } else if let step = self.asFlowClaimDateOfOccurrencePlusLocationStep?.fragments
            .flowClaimDateOfOccurrencePlusLocationStepFragment
        {
            return .setDateOfOccurrencePlusLocation(
                model: .init(
                    dateOfOccurencePlusLocationModel: .init(with: step),
                    dateOfOccurrenceModel: .init(
                        with: step.dateOfOccurrenceStep.fragments.flowClaimDateOfOccurrenceStepFragment
                    ),
                    locationModel: .init(with: step.locationStep.fragments.flowClaimLocationStepFragment)
                )
            )
        } else if let step = self.asFlowClaimPhoneNumberStep?.fragments.flowClaimPhoneNumberStepFragment {
            return .setPhoneNumber(model: .init(with: step))
        } else if let step = self.asFlowClaimAudioRecordingStep?.fragments.flowClaimAudioRecordingStepFragment {
            return .setAudioStep(model: .init(with: step))
        } else if let step = self.asFlowClaimSingleItemStep?.fragments.flowClaimSingleItemStepFragment {
            return .setSingleItem(model: .init(with: step))
        } else if let step = self.asFlowClaimSingleItemCheckoutStep?.fragments.flowClaimSingleItemCheckoutStepFragment {
            return .setSingleItemCheckoutStep(model: .init(with: step))
        } else if let step = self.asFlowClaimLocationStep?.fragments.flowClaimLocationStepFragment {
            return .setLocation(model: .init(with: step))
        } else if let step = self.asFlowClaimSummaryStep?.fragments.flowClaimSummaryStepFragment {
            let summaryStep = FlowClaimSummaryStepModel(with: step)
            let singleItemStepModel: FlowClaimSingleItemStepModel? = {
                if let singleItemStep = step.singleItemStep?.fragments.flowClaimSingleItemStepFragment {
                    return .init(with: singleItemStep)
                }
                return nil
            }()
            return .setSummaryStep(
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
        } else if let step = self.asFlowClaimDateOfOccurrencePlusLocationStep?.fragments
            .flowClaimDateOfOccurrencePlusLocationStepFragment
        {
            return .setDateOfOccurrencePlusLocation(
                model: .init(
                    dateOfOccurencePlusLocationModel: .init(with: step),
                    dateOfOccurrenceModel: .init(
                        with: step.dateOfOccurrenceStep.fragments.flowClaimDateOfOccurrenceStepFragment
                    ),
                    locationModel: .init(with: step.locationStep.fragments.flowClaimLocationStepFragment)
                )
            )
        } else if let step = self.asFlowClaimFailedStep?.fragments.flowClaimFailedStepFragment {
            return .setFailedStep(model: .init(with: step))
        } else if let step = self.asFlowClaimSuccessStep?.fragments.flowClaimSuccessStepFragment {
            return .setSuccessStep(model: .init(with: step))
        } else if let step = self.asFlowClaimContractSelectStep?.fragments.flowClaimContractSelectStepFragment {
            return .setContractSelectStep(model: .init(with: step))
        } else if let step = self.asFlowClaimDeflectEmergencyStep?.fragments.flowClaimDeflectEmergencyStepFragment {
            return .setDeflectModel(model: .init(with: step))
        } else if let step = self.asFlowClaimConfirmEmergencyStep?.fragments.flowClaimConfirmEmergencyStepFragment {
            return .setConfirmDeflectEmergencyStepModel(model: .init(with: step))
        } else if let step = self.asFlowClaimDeflectPestsStep?.fragments.flowClaimDeflectPestsStepFragment {
            return .setDeflectModel(model: .init(with: step))
        } else if let step = self.asFlowClaimDeflectGlassDamageStep?.fragments.flowClaimDeflectGlassDamageStepFragment {
            return .setDeflectModel(model: .init(with: step))
        } else if let step = self.asFlowClaimDeflectTowingStep?.fragments.flowClaimDeflectTowingStepFragment {
            return .setDeflectModel(model: .init(with: step))
        } else if let step = self.asFlowClaimDeflectEirStep?.fragments.flowClaimDeflectEirStepFragment {
            return .setDeflectModel(model: .init(with: step))
        } else if let step = self.asFlowClaimDeflectIDProtectionStep?.fragments.flowClaimDeflectIDProtectionStepFragment
        {
            return .setDeflectModel(model: .init(with: step))
        } else if let step = self.asFlowClaimFileUploadStep?.fragments.flowClaimFileUploadStepFragment {
            return .setFileUploadStep(model: .init(with: step))
        } else {
            return .openUpdateAppScreen
        }
    }
}

private protocol ClaimId {
    func getClaimId() -> String
}

private protocol NextStepId {
    func getNextStepId() -> String
}

private protocol ClaimStepContext {
    func getContext() -> String
}

private protocol ClaimStepProgress {
    func getProgress() -> (clearedSteps: Int?, totalSteps: Int?)
}

extension OctopusGraphQL.FlowClaimStartMutation.Data: ClaimId, NextStepId, ClaimStepContext, ClaimStepProgress {

    func getContext() -> String {
        return self.flowClaimStart.context
    }
    func getProgress() -> (clearedSteps: Int?, totalSteps: Int?) {
        return (
            clearedSteps: self.flowClaimStart.progress?.clearedSteps ?? 0,
            totalSteps: self.flowClaimStart.progress?.totalSteps ?? 0
        )
    }
    func getClaimId() -> String {
        return self.flowClaimStart.id
    }

    func getNextStepId() -> String {
        self.flowClaimStart.currentStep.id
    }
}

extension OctopusGraphQL.FlowClaimDateOfOccurrencePlusLocationNextMutation.Data: ClaimId, NextStepId, ClaimStepContext,
    ClaimStepProgress
{
    func getContext() -> String {
        return self.flowClaimDateOfOccurrencePlusLocationNext.context
    }
    func getClaimId() -> String {
        return self.flowClaimDateOfOccurrencePlusLocationNext.id
    }
    func getProgress() -> (clearedSteps: Int?, totalSteps: Int?) {
        return (
            clearedSteps: self.flowClaimDateOfOccurrencePlusLocationNext.progress?.clearedSteps ?? 0,
            totalSteps: self.flowClaimDateOfOccurrencePlusLocationNext.progress?.totalSteps ?? 0
        )
    }

    func getNextStepId() -> String {
        self.flowClaimDateOfOccurrencePlusLocationNext.currentStep.id
    }
}

extension OctopusGraphQL.FlowClaimContractSelectNextMutation.Data: ClaimId, NextStepId, ClaimStepContext,
    ClaimStepProgress
{
    func getContext() -> String {
        return self.flowClaimContractSelectNext.context
    }
    func getClaimId() -> String {
        return self.flowClaimContractSelectNext.id
    }
    func getProgress() -> (clearedSteps: Int?, totalSteps: Int?) {
        return (
            clearedSteps: self.flowClaimContractSelectNext.progress?.clearedSteps ?? 0,
            totalSteps: self.flowClaimContractSelectNext.progress?.totalSteps ?? 0
        )
    }
    func getNextStepId() -> String {
        self.flowClaimContractSelectNext.currentStep.id
    }
}

extension OctopusGraphQL.FlowClaimConfirmEmergencyNextMutation.Data: ClaimId, NextStepId, ClaimStepContext,
    ClaimStepProgress
{
    func getContext() -> String {
        return self.flowClaimConfirmEmergencyNext.context
    }
    func getClaimId() -> String {
        return self.flowClaimConfirmEmergencyNext.id
    }
    func getProgress() -> (clearedSteps: Int?, totalSteps: Int?) {
        return (
            clearedSteps: self.flowClaimConfirmEmergencyNext.progress?.clearedSteps ?? 0,
            totalSteps: self.flowClaimConfirmEmergencyNext.progress?.totalSteps ?? 0
        )
    }
    func getNextStepId() -> String {
        self.flowClaimConfirmEmergencyNext.currentStep.id
    }
}

extension OctopusGraphQL.FlowClaimAudioRecordingNextMutation.Data: ClaimId, NextStepId, ClaimStepContext,
    ClaimStepProgress
{
    func getContext() -> String {
        return self.flowClaimAudioRecordingNext.context
    }
    func getClaimId() -> String {
        return self.flowClaimAudioRecordingNext.id
    }
    func getProgress() -> (clearedSteps: Int?, totalSteps: Int?) {
        return (
            clearedSteps: self.flowClaimAudioRecordingNext.progress?.clearedSteps ?? 0,
            totalSteps: self.flowClaimAudioRecordingNext.progress?.totalSteps ?? 0
        )
    }
    func getNextStepId() -> String {
        self.flowClaimAudioRecordingNext.currentStep.id
    }
}

extension OctopusGraphQL.FlowClaimPhoneNumberNextMutation.Data: ClaimId, NextStepId, ClaimStepContext, ClaimStepProgress
{
    func getContext() -> String {
        return self.flowClaimPhoneNumberNext.context
    }
    func getClaimId() -> String {
        return self.flowClaimPhoneNumberNext.id
    }
    func getProgress() -> (clearedSteps: Int?, totalSteps: Int?) {
        return (
            clearedSteps: self.flowClaimPhoneNumberNext.progress?.clearedSteps ?? 0,
            totalSteps: self.flowClaimPhoneNumberNext.progress?.totalSteps ?? 0
        )
    }
    func getNextStepId() -> String {
        self.flowClaimPhoneNumberNext.currentStep.id
    }
}

extension OctopusGraphQL.FlowClaimDateOfOccurrenceNextMutation.Data: ClaimId, NextStepId, ClaimStepContext,
    ClaimStepProgress
{
    func getContext() -> String {
        return self.flowClaimDateOfOccurrenceNext.context
    }
    func getClaimId() -> String {
        return self.flowClaimDateOfOccurrenceNext.id
    }
    func getProgress() -> (clearedSteps: Int?, totalSteps: Int?) {
        return (
            clearedSteps: self.flowClaimDateOfOccurrenceNext.progress?.clearedSteps ?? 0,
            totalSteps: self.flowClaimDateOfOccurrenceNext.progress?.totalSteps ?? 0
        )
    }
    func getNextStepId() -> String {
        self.flowClaimDateOfOccurrenceNext.currentStep.id
    }
}

extension OctopusGraphQL.FlowClaimLocationNextMutation.Data: ClaimId, NextStepId, ClaimStepContext, ClaimStepProgress {
    func getContext() -> String {
        return self.flowClaimLocationNext.context
    }
    func getClaimId() -> String {
        return self.flowClaimLocationNext.id
    }
    func getProgress() -> (clearedSteps: Int?, totalSteps: Int?) {
        return (
            clearedSteps: self.flowClaimLocationNext.progress?.clearedSteps ?? 0,
            totalSteps: self.flowClaimLocationNext.progress?.totalSteps ?? 0
        )
    }
    func getNextStepId() -> String {
        self.flowClaimLocationNext.currentStep.id
    }
}

extension OctopusGraphQL.FlowClaimSingleItemNextMutation.Data: ClaimId, NextStepId, ClaimStepContext, ClaimStepProgress
{
    func getContext() -> String {
        return self.flowClaimSingleItemNext.context
    }
    func getClaimId() -> String {
        return self.flowClaimSingleItemNext.id
    }
    func getProgress() -> (clearedSteps: Int?, totalSteps: Int?) {
        return (
            clearedSteps: self.flowClaimSingleItemNext.progress?.clearedSteps ?? 0,
            totalSteps: self.flowClaimSingleItemNext.progress?.totalSteps ?? 0
        )
    }
    func getNextStepId() -> String {
        self.flowClaimSingleItemNext.currentStep.id
    }
}

extension OctopusGraphQL.FlowClaimSummaryNextMutation.Data: ClaimId, NextStepId, ClaimStepContext, ClaimStepProgress {
    func getContext() -> String {
        return self.flowClaimSummaryNext.context
    }
    func getClaimId() -> String {
        return self.flowClaimSummaryNext.id
    }
    func getProgress() -> (clearedSteps: Int?, totalSteps: Int?) {
        return (
            clearedSteps: self.flowClaimSummaryNext.progress?.clearedSteps ?? 0,
            totalSteps: self.flowClaimSummaryNext.progress?.totalSteps ?? 0
        )
    }
    func getNextStepId() -> String {
        self.flowClaimSummaryNext.currentStep.id
    }
}

extension OctopusGraphQL.FlowClaimSingleItemCheckoutNextMutation.Data: ClaimId, NextStepId, ClaimStepContext,
    ClaimStepProgress
{
    func getContext() -> String {
        return self.flowClaimSingleItemCheckoutNext.context
    }
    func getClaimId() -> String {
        return self.flowClaimSingleItemCheckoutNext.id
    }
    func getProgress() -> (clearedSteps: Int?, totalSteps: Int?) {
        return (
            clearedSteps: self.flowClaimSingleItemCheckoutNext.progress?.clearedSteps ?? 0,
            totalSteps: self.flowClaimSingleItemCheckoutNext.progress?.totalSteps ?? 0
        )
    }
    func getNextStepId() -> String {
        self.flowClaimSingleItemCheckoutNext.currentStep.id
    }
}

extension OctopusGraphQL.FlowClaimFileUploadNextMutation.Data: ClaimId, NextStepId, ClaimStepContext, ClaimStepProgress
{
    func getContext() -> String {
        return self.flowClaimFileUploadNext.context
    }
    func getClaimId() -> String {
        return self.flowClaimFileUploadNext.id
    }
    func getProgress() -> (clearedSteps: Int?, totalSteps: Int?) {
        return (
            clearedSteps: self.flowClaimFileUploadNext.progress?.clearedSteps ?? 0,
            totalSteps: self.flowClaimFileUploadNext.progress?.totalSteps ?? 0
        )
    }
    func getNextStepId() -> String {
        self.flowClaimFileUploadNext.currentStep.id
    }
}

extension FlowClaimSuccessStepModel {
    fileprivate init(
        with data: OctopusGraphQL.FlowClaimSuccessStepFragment
    ) {
        self.init(id: data.id)
    }
}

extension FlowClaimFailedStepModel {
    fileprivate init(
        with data: OctopusGraphQL.FlowClaimFailedStepFragment
    ) {
        self.init(id: data.id)
    }
}

extension FlowClaimDateOfOccurenceStepModel {
    fileprivate init(
        with data: OctopusGraphQL.FlowClaimDateOfOccurrenceStepFragment
    ) {
        self.init(
            id: data.id,
            dateOfOccurence: data.dateOfOccurrence,
            maxDate: data.maxDate
        )
    }
}

extension FlowClaimDateOfOccurrencePlusLocationStepModel {
    fileprivate init(
        with data: OctopusGraphQL.FlowClaimDateOfOccurrencePlusLocationStepFragment
    ) {
        self.init(id: data.id)
    }
}

extension FlowClaimLocationStepModel {
    fileprivate init(
        with data: OctopusGraphQL.FlowClaimLocationStepFragment
    ) {
        self.init(
            id: data.id,
            location: data.location,
            options: data.options.map({ .init(with: $0) })
        )
    }
}

extension FlowClaimAudioRecordingStepModel {
    fileprivate init?(
        with data: OctopusGraphQL.FlowClaimAudioRecordingStepFragment?
    ) {
        guard let data else {
            return nil
        }
        self.init(
            id: data.id,
            questions: data.questions,
            audioContent: .init(with: (data.audioContent?.fragments.flowClaimAudioContentFragment)),
            textQuestions: data.freeTextQuestions,
            inputTextContent: data.freeText,
            optionalAudio: data.freeTextAvailable
        )
    }
}

extension FlowClaimPhoneNumberStepModel {
    fileprivate init(
        with data: OctopusGraphQL.FlowClaimPhoneNumberStepFragment
    ) {
        self.init(
            id: data.id,
            phoneNumber: data.phoneNumber
        )
    }
}

@MainActor
extension FlowClaimContractSelectStepModel {
    fileprivate init(
        with data: OctopusGraphQL.FlowClaimContractSelectStepFragment
    ) {
        self.init(
            availableContractOptions: data.options.map({ .init(with: $0) }),
            selectedContractId: data.selectedOptionId ?? data.options.first?.id
        )
    }
}

@MainActor
extension FlowClaimContractSelectOptionModel {
    fileprivate init(
        with data: OctopusGraphQL.FlowClaimContractSelectStepFragment.Option
    ) {
        self.init(
            displayTitle: data.displayTitle,
            displaySubTitle: data.displaySubtitle,
            id: data.id
        )
    }
}

extension FlowClaimConfirmEmergencyStepModel {
    fileprivate init(
        with data: OctopusGraphQL.FlowClaimConfirmEmergencyStepFragment
    ) {
        self.init(
            id: data.id,
            text: data.text,
            confirmEmergency: data.confirmEmergency,
            options: data.options.map({ data in
                FlowClaimConfirmEmergencyOption(displayName: data.displayName, value: data.displayValue)
            })
        )
    }
}

extension FlowClaimFileUploadStepModel {
    fileprivate init?(
        with data: OctopusGraphQL.FlowClaimFileUploadStepFragment?
    ) {
        guard let data else {
            return nil
        }
        self.init(
            id: data.id,
            title: data.title,
            targetUploadUrl: data.targetUploadUrl,
            uploads: data.uploads.compactMap({
                FlowClaimFileUploadStepFileModel(
                    fileId: $0.fileId,
                    signedUrl: $0.signedUrl,
                    mimeType: $0.mimeType,
                    name: $0.name
                )
            })
        )
    }
}

extension FlowClaimSummaryStepModel {
    fileprivate init(
        with data: OctopusGraphQL.FlowClaimSummaryStepFragment
    ) {
        self.init(
            id: data.id,
            title: data.title,
            subtitle: data.subtitle,
            shouldShowDateOfOccurence: true,
            shouldShowLocation: true,
            shouldShowSingleItem: data.singleItemStep != nil,
            selectedContractExposure: data.selectContractStep?.options
                .first(where: { it in
                    it.id == data.selectContractStep?.selectedOptionId
                })?
                .displaySubtitle
        )
    }
}

extension AudioContentModel {
    fileprivate init?(
        with data: OctopusGraphQL.FlowClaimAudioContentFragment?
    ) {
        guard let data else {
            return nil
        }
        self.init(
            audioUrl: data.audioUrl,
            signedUrl: data.signedUrl
        )
    }
}

extension FlowClaimDeflectStepModel {
    fileprivate init(
        with data: OctopusGraphQL.FlowClaimDeflectPestsStepFragment
    ) {
        self.init(
            id: (Self.setDeflectType(idIn: data.id)),
            infoText: L10n.submitClaimPestsInfoLabel,
            warningText: nil,
            infoSectionText: L10n.submitClaimPestsHowItWorksLabel,
            infoSectionTitle: L10n.submitClaimHowItWorksTitle,
            infoViewTitle: L10n.submitClaimPestsTitle,
            infoViewText: L10n.submitClaimPestsInfoLabel,
            questions: [],
            partners: data.partners.map({
                .init(
                    with: $0.fragments.flowClaimDeflectPartnerFragment,
                    title: nil,
                    description: L10n.submitClaimPestsCustomerServiceLabel,
                    info: nil,
                    buttonText: L10n.submitClaimPestsCustomerServiceButton
                )
            })
        )
    }

    fileprivate init(
        with data: OctopusGraphQL.FlowClaimDeflectGlassDamageStepFragment
    ) {
        self.init(
            id: (Self.setDeflectType(idIn: data.id)),
            infoText: L10n.submitClaimGlassDamageInfoLabel,
            warningText: nil,
            infoSectionText: L10n.submitClaimGlassDamageHowItWorksLabel,
            infoSectionTitle: L10n.submitClaimHowItWorksTitle,
            infoViewTitle: L10n.submitClaimGlassDamageTitle,
            infoViewText: L10n.submitClaimGlassDamageInfoLabel,
            questions: [],
            partners: data.partners.map({
                .init(
                    with: $0.fragments.flowClaimDeflectPartnerFragment,
                    title: nil,
                    description: L10n.submitClaimGlassDamageOnlineBookingLabel,
                    info: nil,
                    buttonText: L10n.submitClaimGlassDamageOnlineBookingButton
                )
            })
        )
    }

    fileprivate init(
        with data: OctopusGraphQL.FlowClaimDeflectTowingStepFragment
    ) {
        self.init(
            id: (Self.setDeflectType(idIn: data.id)),
            infoText: L10n.submitClaimTowingInfoLabel,
            warningText: nil,
            infoSectionText: L10n.submitClaimTowingHowItWorksLabel,
            infoSectionTitle: L10n.submitClaimHowItWorksTitle,
            infoViewTitle: L10n.submitClaimTowingTitle,
            infoViewText: L10n.submitClaimTowingInfoLabel,
            questions: [
                .init(question: L10n.submitClaimTowingQ1, answer: L10n.submitClaimTowingA1),
                .init(question: L10n.submitClaimTowingQ2, answer: L10n.submitClaimTowingA2),
                .init(question: L10n.submitClaimTowingQ3, answer: L10n.submitClaimTowingA3),
            ],
            partners: data.partners.map({
                .init(
                    with: $0.fragments.flowClaimDeflectPartnerFragment,
                    title: nil,
                    description: L10n.submitClaimTowingOnlineBookingLabel,
                    info: nil,
                    buttonText: L10n.submitClaimTowingOnlineBookingButton
                )
            })
        )
    }

    fileprivate init(
        with data: OctopusGraphQL.FlowClaimDeflectEirStepFragment
    ) {
        self.init(
            id: (Self.setDeflectType(idIn: data.id)),
            infoText: nil,
            warningText: nil,
            infoSectionText: nil,
            infoSectionTitle: nil,
            infoViewTitle: nil,
            infoViewText: nil,
            questions: [],
            partners: data.partners.map({
                .init(
                    with: $0.fragments.flowClaimDeflectPartnerFragment,
                    title: nil,
                    description: nil,
                    info: nil,
                    buttonText: nil
                )
            })
        )
    }

    fileprivate init(
        with data: OctopusGraphQL.FlowClaimDeflectIDProtectionStepFragment
    ) {
        self.init(
            id: (Self.setDeflectType(idIn: data.id)),
            infoText: nil,
            warningText: nil,
            infoSectionText: data.description,
            infoSectionTitle: data.title,
            infoViewTitle: nil,
            infoViewText: nil,
            questions: [],
            partners: data.partners.map({
                .init(
                    with: $0.deflectPartner.fragments.flowClaimDeflectPartnerFragment,
                    title: $0.title,
                    description: $0.description,
                    info: $0.info,
                    buttonText: $0.urlButtonTitle
                )
            })
        )
    }

    fileprivate init(
        with data: OctopusGraphQL.FlowClaimDeflectEmergencyStepFragment
    ) {
        self.init(
            id: (Self.setDeflectType(idIn: data.id)),
            infoText: nil,
            warningText: L10n.submitClaimEmergencyInfoLabel,
            infoSectionText: L10n.submitClaimEmergencyInsuranceCoverLabel,
            infoSectionTitle: L10n.submitClaimEmergencyInsuranceCoverTitle,
            infoViewTitle: nil,
            infoViewText: nil,
            questions: [
                .init(question: L10n.submitClaimEmergencyFaq1Title, answer: L10n.submitClaimEmergencyFaq1Label),
                .init(question: L10n.submitClaimEmergencyFaq2Title, answer: L10n.submitClaimEmergencyFaq2Label),
                .init(question: L10n.submitClaimEmergencyFaq3Title, answer: L10n.submitClaimEmergencyFaq3Label),
                .init(question: L10n.submitClaimEmergencyFaq4Title, answer: L10n.submitClaimEmergencyFaq4Label),
                .init(question: L10n.submitClaimEmergencyFaq5Title, answer: L10n.submitClaimEmergencyFaq5Label),
                .init(question: L10n.submitClaimEmergencyFaq6Title, answer: L10n.submitClaimEmergencyFaq6Label),
                .init(question: L10n.submitClaimEmergencyFaq7Title, answer: L10n.submitClaimEmergencyFaq7Label),
                .init(question: L10n.submitClaimEmergencyFaq8Title, answer: L10n.submitClaimEmergencyFaq8Label),

            ],
            partners: data.partners.map({
                .init(
                    with: $0.fragments.flowClaimDeflectPartnerFragment,
                    title: L10n.submitClaimEmergencyGlobalAssistanceTitle,
                    description: L10n.submitClaimEmergencyGlobalAssistanceLabel,
                    info: L10n.submitClaimGlobalAssistanceFootnote,
                    buttonText: L10n.submitClaimGlobalAssistanceUrlLabel
                )
            })
        )
    }
}

extension Partner {
    fileprivate init(
        with data: OctopusGraphQL.FlowClaimDeflectPartnerFragment,
        title: String?,
        description: String?,
        info: String?,
        buttonText: String?
    ) {
        self.init(
            id: data.id,
            imageUrl: data.imageUrl,
            url: data.url,
            phoneNumber: data.phoneNumber,
            title: title,
            description: description,
            info: info,
            buttonText: buttonText,
            preferredImageHeight: data.preferredImageHeight
        )
    }
}
extension ClaimFlowLocationOptionModel {
    fileprivate init(
        with data: OctopusGraphQL.FlowClaimLocationStepFragment.Option
    ) {
        self.init(displayName: data.displayName, value: data.value)
    }
}

@MainActor
extension FlowClaimSingleItemCheckoutStepModel {
    fileprivate init(
        with data: OctopusGraphQL.FlowClaimSingleItemCheckoutStepFragment
    ) {
        let flowClaimSingleItemStepModel: FlowClaimSingleItemStepModel? = {
            if let singleItemFragment = data.singleItemStep?.fragments.flowClaimSingleItemStepFragment {
                return .init(with: singleItemFragment)
            } else {
                return nil
            }
        }()
        let payoutMethods = data.availableCheckoutMethods.compactMap({
            let id = $0.id
            if $0.__typename == "FlowClaimAutomaticAutogiroPayout" {
                let fragment = $0.asFlowClaimAutomaticAutogiroPayout!.fragments.flowClaimAutomaticAutogiroPayoutFragment
                return AvailableCheckoutMethod(
                    id: id,
                    autogiro: ClaimAutomaticAutogiroPayoutModel.init(
                        id: fragment.id,
                        amount: .init(fragment: fragment.amount.fragments.moneyFragment),
                        displayName: fragment.displayName
                    )
                )
            }
            return nil
        })
        let compensationFragment = data.compensation.fragments.flowClaimSingleItemCheckoutCompensationFragment

        let compensation = Compensation(
            id: compensationFragment.id,
            deductible: .init(fragment: compensationFragment.deductible.fragments.moneyFragment),
            payoutAmount: .init(fragment: compensationFragment.payoutAmount.fragments.moneyFragment),
            repairCompensation: .init(with: compensationFragment.asFlowClaimSingleItemCheckoutRepairCompensation),
            valueCompensation: .init(with: compensationFragment.asFlowClaimSingleItemCheckoutValueCompensation)
        )

        self.init(
            id: data.id,
            payoutMethods: payoutMethods,
            selectedPayoutMethod: payoutMethods.first,
            compensation: compensation,
            singleItemModel: flowClaimSingleItemStepModel
        )
    }

    fileprivate func returnSingleItemCheckoutInfo() -> OctopusGraphQL.FlowClaimSingleItemCheckoutInput? {
        return selectedPayoutMethod?.getCheckoutInput(forAmount: Double(compensation.payoutAmount.floatAmount))
    }
}

@MainActor
extension FlowClaimSingleItemStepModel {
    fileprivate init(
        with data: OctopusGraphQL.FlowClaimSingleItemStepFragment
    ) {
        var selectedItemModel = data.selectedItemModel
        let customName = data.customName
        let availableItemModelOptions =
            data.availableItemModels?
            .map({
                ClaimFlowItemModelOptionModel.init(
                    displayName: $0.displayName,
                    itemBrandId: $0.itemBrandId,
                    itemTypeId: $0.itemTypeId,
                    itemModelId: $0.itemModelId
                )
            }) ?? []
        var selectedItemBrand = data.selectedItemBrand
        if selectedItemModel == nil && customName == nil {
            let currentDeviceName = UIDevice.modelName.lowercased()
            if let matchingModelWithCurrentDevice = availableItemModelOptions.first(where: {
                let name = $0.displayName.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                return name == currentDeviceName
            }) {
                selectedItemModel = matchingModelWithCurrentDevice.itemModelId
                selectedItemBrand = matchingModelWithCurrentDevice.itemBrandId
            }
        }
        self.init(
            id: data.id,
            availableItemBrandOptions: data.availableItemBrands?
                .map({
                    ClaimFlowItemBrandOptionModel.init(
                        displayName: $0.displayName,
                        itemBrandId: $0.itemBrandId,
                        itemTypeId: $0.itemTypeId
                    )
                }) ?? [],
            availableItemModelOptions: availableItemModelOptions,
            availableItemProblems: data.availableItemProblems?
                .map({
                    ClaimFlowItemProblemOptionModel.init(displayName: $0.displayName, itemProblemId: $0.itemProblemId)
                }) ?? [],
            customName: customName,
            prefferedCurrency: data.preferredCurrency.rawValue,
            purchaseDate: data.purchaseDate,
            purchasePrice: data.purchasePrice?.amount,
            currencyCode: data.purchasePrice?.currencyCode.rawValue,
            selectedItemBrand: selectedItemBrand,
            selectedItemModel: selectedItemModel,
            selectedItemProblems: data.selectedItemProblems,
            defaultItemProblems: nil,
            purchasePriceApplicable: data.purchasePriceApplicable
        )

    }
}

extension Compensation.RepairCompensation {
    fileprivate init?(
        with data: OctopusGraphQL.FlowClaimSingleItemCheckoutCompensationFragment
            .AsFlowClaimSingleItemCheckoutRepairCompensation?
    ) {
        guard let data else {
            return nil
        }
        self.init(
            repairCost: .init(fragment: data.repairCost.fragments.moneyFragment)
        )
    }
}

extension Compensation.ValueCompensation {
    fileprivate init?(
        with data: OctopusGraphQL.FlowClaimSingleItemCheckoutCompensationFragment
            .AsFlowClaimSingleItemCheckoutValueCompensation?
    ) {
        guard let data else {
            return nil
        }
        self.init(
            depreciation: .init(fragment: data.depreciation.fragments.moneyFragment),
            price: .init(fragment: data.price.fragments.moneyFragment)
        )
    }
}

extension AvailableCheckoutMethod {
    fileprivate func getCheckoutInput(forAmount amount: Double) -> OctopusGraphQL.FlowClaimSingleItemCheckoutInput? {
        if autogiro != nil {
            let automaticAutogiroInput = OctopusGraphQL.FlowClaimAutomaticAutogiroPayoutInput(
                amount: amount
            )

            return OctopusGraphQL.FlowClaimSingleItemCheckoutInput(
                automaticAutogiro: GraphQLNullable(optionalValue: automaticAutogiroInput)
            )
        }
        return nil
    }
}

extension FlowClaimSingleItemStepModel {
    @MainActor
    fileprivate func returnSingleItemInfo(purchasePrice: Double?) -> OctopusGraphQL.FlowClaimSingleItemInput {
        let itemBrandInput: OctopusGraphQL.FlowClaimItemBrandInput? = {
            if selectedItemModel != nil {
                return nil
            }
            guard let selectedItemBrand,
                let selectedBrand = availableItemBrandOptions.first(where: { $0.itemBrandId == selectedItemBrand })
            else {
                return nil
            }
            return OctopusGraphQL.FlowClaimItemBrandInput(
                itemTypeId: selectedBrand.itemTypeId,
                itemBrandId: selectedBrand.itemBrandId
            )
        }()

        let itemModelInput: OctopusGraphQL.FlowClaimItemModelInput? = {
            guard let selectedItemModel else { return nil }
            return OctopusGraphQL.FlowClaimItemModelInput(itemModelId: selectedItemModel)

        }()

        let problemsIds = self.selectedItemProblems ?? defaultItemProblems ?? []
        return OctopusGraphQL.FlowClaimSingleItemInput(
            purchasePrice: GraphQLNullable(optionalValue: purchasePrice == 0 ? nil : purchasePrice),
            purchaseDate: GraphQLNullable(optionalValue: purchaseDate?.localDateToDate?.localDateString),
            itemProblemIds: GraphQLNullable(optionalValue: problemsIds),
            itemBrandInput: GraphQLNullable(optionalValue: itemBrandInput),
            itemModelInput: GraphQLNullable(optionalValue: itemModelInput),
            customName: GraphQLNullable(optionalValue: customName)
        )
    }
}

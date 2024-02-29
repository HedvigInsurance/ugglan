import Combine
import Flow
import Foundation
import Presentation
import hCore
import hGraphQL

public class SubmitClaimServiceOctopus: SubmitClaimService {
    public init() {}
    @PresentableStore var store: SubmitClaimStore

    public func startClaim(entrypointId: String?, entrypointOptionId: String?) async throws -> SubmitClaimStepResponse {
        let startInput = OctopusGraphQL.FlowClaimStartInput(
            entrypointId: GraphQLNullable(optionalValue: entrypointId),
            entrypointOptionId: GraphQLNullable(optionalValue: entrypointOptionId)
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
                        audioUrl: GraphQLNullable(optionalValue: url)
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

                    let fileUploaderData = try fileUploaderClient.upload(
                        flowId: store.state.currentClaimId,
                        file: uploadFile
                    )

                    var mutation = OctopusGraphQL.FlowClaimAudioRecordingNextMutation(input: .init(), context: context)

                    fileUploaderData.onValue { responseModel in
                        let audioInput = OctopusGraphQL.FlowClaimAudioRecordingInput(
                            audioUrl: GraphQLNullable(optionalValue: responseModel.audioUrl)
                        )

                        mutation = OctopusGraphQL.FlowClaimAudioRecordingNextMutation(
                            input: audioInput,
                            context: context
                        )

                    }
                    return try await mutation.execute(
                        \.flowClaimAudioRecordingNext.fragments.flowClaimFragment.currentStep
                    )
                }
            } catch {
                throw SubmitClaimError.error(message: error.localizedDescription)
            }
        case let .text(text):
            let audioInput = OctopusGraphQL.FlowClaimAudioRecordingInput(
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
}

extension GraphQLMutation {
    func execute<ClaimStep: Into>(_ keyPath: KeyPath<Self.Data, ClaimStep>) async throws -> SubmitClaimStepResponse
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
            let action = data[keyPath: keyPath].into()
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

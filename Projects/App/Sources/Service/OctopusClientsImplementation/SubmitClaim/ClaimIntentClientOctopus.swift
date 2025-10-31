import Foundation
import SubmitClaim
import hCore
import hGraphQL

class ClaimIntentClientOctopus: ClaimIntentClient {
    @Inject private var octopus: hOctopus

    func startClaimIntent() async throws -> ClaimIntent {
        let mutation = OctopusGraphQL.ClaimIntentStartMutation()
        let data = try await octopus.client.mutation(mutation: mutation)

        let currentStep = data?.claimIntentStart.currentStep
        let id = data?.claimIntentStart.id ?? ""

        if let currentStepFragment = currentStep?.fragments.claimIntentStepFragment {
            return .init(currentStep: .init(fragment: currentStepFragment), id: id)
        }

        return .init(
            currentStep: .init(content: .task(model: .init(description: "", isCompleted: false)), id: "", text: ""),
            id: ""
        )
    }

    func claimIntentSubmitAudio(reference: String?, freeText: String?, stepId: String) async throws -> ClaimIntent {
        //        let input = OctopusGraphQL.ClaimIntentSubmitAudioInput(stepId: stepId, audioReference: .init(optionalValue: reference), freeText: .init(optionalValue: freeText))

        let input = OctopusGraphQL.ClaimIntentSubmitAudioInput(
            stepId: stepId,
            audioReference: GraphQLNullable(optionalValue: nil),
            freeText: GraphQLNullable(optionalValue: "freeText")
        )

        let mutation = OctopusGraphQL.ClaimIntentSubmitAudioMutation(input: input)
        let data = try await octopus.client.mutation(mutation: mutation)

        let currentStep = data?.claimIntentSubmitAudio.intent?.currentStep
        let id = data?.claimIntentSubmitAudio.intent?.id ?? ""

        if let currentStepFragment = currentStep?.fragments.claimIntentStepFragment {
            return .init(currentStep: .init(fragment: currentStepFragment), id: id)
        }

        if let userError = data?.claimIntentSubmitAudio.userError {
            print("audio error: ", userError)
        }

        return .init(
            currentStep: .init(content: .task(model: .init(description: "", isCompleted: false)), id: "", text: ""),
            id: ""
        )
    }

    func claimIntentSubmitForm(
        fields: [ClaimIntentStepContentForm.ClaimIntentStepContentFormField],
        stepId: String
    ) async throws -> ClaimIntent {
        let fieldInput: [OctopusGraphQL.ClaimIntentFormSubmitInputField] = fields.map {
            .init(fieldId: $0.id, values: [])
        }
        let input = OctopusGraphQL.ClaimIntentSubmitFormInput(stepId: stepId, fields: fieldInput)
        let mutation = OctopusGraphQL.ClaimIntentSubmitFormMutation(input: input)
        let data = try await octopus.client.mutation(mutation: mutation)

        let currentStep = data?.claimIntentSubmitForm.intent?.currentStep
        let id = data?.claimIntentSubmitForm.intent?.id ?? ""

        if let currentStepFragment = currentStep?.fragments.claimIntentStepFragment {
            return .init(currentStep: .init(fragment: currentStepFragment), id: id)
        }

        return .init(
            currentStep: .init(content: .task(model: .init(description: "", isCompleted: false)), id: "", text: ""),
            id: ""
        )
    }

    func claimIntentSubmitSummary(stepId: String) async throws -> ClaimIntent {
        let input = OctopusGraphQL.ClaimIntentSubmitSummaryInput(stepId: stepId)
        let mutation = OctopusGraphQL.ClaimIntentSubmitSummaryMutation(input: input)
        let data = try await octopus.client.mutation(mutation: mutation)

        let currentStep = data?.claimIntentSubmitSummary.intent?.currentStep
        let id = data?.claimIntentSubmitSummary.intent?.id ?? ""

        if let currentStepFragment = currentStep?.fragments.claimIntentStepFragment {
            return .init(currentStep: .init(fragment: currentStepFragment), id: id)
        }

        return .init(
            currentStep: .init(content: .task(model: .init(description: "", isCompleted: false)), id: "", text: ""),
            id: ""
        )
    }

    func claimIntentSubmitTask(stepId: String) async throws -> ClaimIntent {
        let input = OctopusGraphQL.ClaimIntentSubmitTaskInput(stepId: stepId)
        let mutation = OctopusGraphQL.ClaimIntentSubmitTaskMutation(input: input)
        let data = try await octopus.client.mutation(mutation: mutation)

        let currentStep = data?.claimIntentSubmitTask.intent?.currentStep
        let id = data?.claimIntentSubmitTask.intent?.id ?? ""

        if let currentStepFragment = currentStep?.fragments.claimIntentStepFragment {
            return .init(currentStep: .init(fragment: currentStepFragment), id: id)
        }

        return .init(
            currentStep: .init(content: .task(model: .init(description: "", isCompleted: false)), id: "", text: ""),
            id: ""
        )
    }

    func getNextStep(claimIntentId: String) async throws -> ClaimIntentStep {
        let query = OctopusGraphQL.ClaimIntentQuery(claimIntentId: claimIntentId)
        let data = try await octopus.client.fetch(query: query)

        return ClaimIntentStep(fragment: data.claimIntent.currentStep.fragments.claimIntentStepFragment)
    }
}

extension ClaimIntentStep {
    init(
        fragment: OctopusGraphQL.ClaimIntentStepFragment
    ) {
        self.init(
            content: .init(fragment: fragment.content.fragments.claimIntentStepContentFragment),
            id: fragment.id,
            text: fragment.text
        )
    }
}

extension ClaimIntentStepContent {
    init(
        fragment: OctopusGraphQL.ClaimIntentStepContentFragment
    ) {
        if let form = fragment.asClaimIntentStepContentForm {
            let fields = form.fields.map {
                ClaimIntentStepContentForm.ClaimIntentStepContentFormField(
                    fragment: $0.fragments.claimIntentStepContentFormFieldFragment
                )
            }

            self = .form(model: .init(fields: fields))
        } else if let task = fragment.asClaimIntentStepContentTask {
            self = .task(model: .init(description: task.description, isCompleted: task.isCompleted))
        } else if let audioRecording = fragment.asClaimIntentStepContentAudioRecording {
            self = .audioRecording(model: .init(hint: audioRecording.hint))
        } else if let summary = fragment.asClaimIntentStepContentSummary {
            self = .summary(
                model: .init(
                    audioRecordings: summary.audioRecordings.map { .init(url: URL(string: $0.url)!) },
                    fileUploads: summary.fileUploads.map { .init(url: URL(string: $0.url)!) },
                    items: summary.items.map { .init(title: $0.title, value: $0.value) }
                )
            )
        } else {
            self = .summary(model: .init(audioRecordings: [], fileUploads: [], items: []))
        }
    }
}

extension ClaimIntentStepContentForm.ClaimIntentStepContentFormField {
    init(
        fragment: OctopusGraphQL.ClaimIntentStepContentFormFieldFragment
    ) {
        self.init(
            defaultValue: fragment.defaultValue,
            id: fragment.id,
            isRequired: fragment.isRequired,
            maxValue: fragment.maxValue,
            minValue: fragment.minValue,
            options: fragment.options?.map { .init(title: $0.title, value: $0.value) } ?? [],
            suffix: fragment.suffix,
            title: fragment.title,
            type: fragment.type.value?.asType ?? .text
        )
    }
}

extension OctopusGraphQL.ClaimIntentStepContentFormFieldType {
    public var asType: ClaimIntentStepContentForm.ClaimIntentStepContentFormFieldType {
        switch self {
        case .text:
            return .text
        case .date:
            return .date
        case .number:
            return .number
        case .singleSelect:
            return .singleSelect
        case .binary:
            return .binary
        }
    }
}

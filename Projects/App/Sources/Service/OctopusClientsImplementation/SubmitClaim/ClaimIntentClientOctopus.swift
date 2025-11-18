import Foundation
import SubmitClaimChat
import hCore
import hGraphQL

class ClaimIntentClientOctopus: ClaimIntentClient {
    @Inject private var octopus: hOctopus

    func startClaimIntent(input: StartClaimInput) async throws -> ClaimIntent? {
        let input: OctopusGraphQL.ClaimIntentStartInput = .init(
            sourceMessageId: GraphQLNullable(optionalValue: input.sourceMessageId),
            developmentFlow: GraphQLNullable(optionalValue: input.devFlow)
        )
        let mutation = OctopusGraphQL.ClaimIntentStartMutation(input: GraphQLNullable(input))

        do {
            let data = try await octopus.client.mutation(mutation: mutation)

            let currentStep = data?.claimIntentStart.currentStep
            let id = data?.claimIntentStart.id ?? ""
            let sourceMessages: [SourceMessage] =
                data?.claimIntentStart.sourceMessages?
                .compactMap { .init(fragment: $0.fragments.claimIntentSourceMessageFragment) } ?? []

            if let currentStepFragment = currentStep?.fragments.claimIntentStepFragment {
                return .init(currentStep: .init(fragment: currentStepFragment), id: id, sourceMessages: sourceMessages)
            }
        } catch {
            throw SubmitClaimError.error(message: error.localizedDescription)
        }
        return nil
    }

    func claimIntentSubmitAudio(fileId: String?, freeText: String?, stepId: String) async throws -> ClaimIntent? {
        let input = OctopusGraphQL.ClaimIntentSubmitAudioInput(
            stepId: stepId,
            audioFileId: GraphQLNullable(optionalValue: fileId),
            freeText: GraphQLNullable(optionalValue: nil)
        )

        let mutation = OctopusGraphQL.ClaimIntentSubmitAudioMutation(input: input)

        do {
            let data = try await octopus.client.mutation(mutation: mutation)

            if let userError = data?.claimIntentSubmitAudio.userError, let message = userError.message {
                throw SubmitClaimError.error(message: message)
            }

            let currentStep = data?.claimIntentSubmitAudio.intent?.currentStep
            let id = data?.claimIntentSubmitAudio.intent?.id ?? ""
            let sourceMessages: [SourceMessage] =
                data?.claimIntentSubmitAudio.intent?.sourceMessages?
                .compactMap { .init(fragment: $0.fragments.claimIntentSourceMessageFragment) } ?? []

            if let currentStepFragment = currentStep?.fragments.claimIntentStepFragment {
                return .init(currentStep: .init(fragment: currentStepFragment), id: id, sourceMessages: sourceMessages)
            }
        } catch {
            throw SubmitClaimError.error(message: error.localizedDescription)
        }

        return nil
    }

    func claimIntentSubmitFile(stepId: String, fildIds: [String]) async throws -> ClaimIntent? {
        let input = OctopusGraphQL.ClaimIntentSubmitFileUploadInput(
            stepId: stepId,
            fileIds: fildIds
        )

        let mutation = OctopusGraphQL.ClaimIntentSubmitFileUploadMutation(input: input)
        do {
            let data = try await octopus.client.mutation(mutation: mutation)

            if let userError = data?.claimIntentSubmitFileUpload.userError, let message = userError.message {
                throw SubmitClaimError.error(message: message)
            }

            let currentStep = data?.claimIntentSubmitFileUpload.intent?.currentStep
            let id = data?.claimIntentSubmitFileUpload.intent?.id ?? ""
            let sourceMessages: [SourceMessage] =
                data?.claimIntentSubmitFileUpload.intent?.sourceMessages?
                .compactMap { .init(fragment: $0.fragments.claimIntentSourceMessageFragment) } ?? []

            if let currentStepFragment = currentStep?.fragments.claimIntentStepFragment {
                return .init(currentStep: .init(fragment: currentStepFragment), id: id, sourceMessages: sourceMessages)
            }
        } catch {
            throw SubmitClaimError.error(message: error.localizedDescription)
        }

        return nil
    }

    func claimIntentSubmitForm(
        fields: [FieldValue],
        stepId: String
    ) async throws -> ClaimIntent? {
        let fieldInput: [OctopusGraphQL.ClaimIntentFormSubmitInputField] = fields.map {
            .init(fieldId: $0.id, values: GraphQLNullable(optionalValue: $0.values))
        }
        let input = OctopusGraphQL.ClaimIntentSubmitFormInput(stepId: stepId, fields: fieldInput)
        let mutation = OctopusGraphQL.ClaimIntentSubmitFormMutation(input: input)

        do {
            let data = try await octopus.client.mutation(mutation: mutation)
            if let userError = data?.claimIntentSubmitForm.userError, let message = userError.message {
                throw SubmitClaimError.error(message: message)
            }

            let currentStep = data?.claimIntentSubmitForm.intent?.currentStep
            let id = data?.claimIntentSubmitForm.intent?.id ?? ""
            let sourceMessages: [SourceMessage] =
                data?.claimIntentSubmitForm.intent?.sourceMessages?
                .compactMap { .init(fragment: $0.fragments.claimIntentSourceMessageFragment) } ?? []

            if let currentStepFragment = currentStep?.fragments.claimIntentStepFragment {
                return .init(currentStep: .init(fragment: currentStepFragment), id: id, sourceMessages: sourceMessages)
            }
        } catch {
            throw SubmitClaimError.error(message: error.localizedDescription)
        }

        return nil
    }

    func claimIntentSubmitSummary(stepId: String) async throws -> ClaimIntent? {
        let input = OctopusGraphQL.ClaimIntentSubmitSummaryInput(stepId: stepId)
        let mutation = OctopusGraphQL.ClaimIntentSubmitSummaryMutation(input: input)

        do {
            let data = try await octopus.client.mutation(mutation: mutation)
            if let userError = data?.claimIntentSubmitSummary.userError, let message = userError.message {
                throw SubmitClaimError.error(message: message)
            }

            let currentStep = data?.claimIntentSubmitSummary.intent?.currentStep
            let id = data?.claimIntentSubmitSummary.intent?.id ?? ""
            let sourceMessages: [SourceMessage] =
                data?.claimIntentSubmitSummary.intent?.sourceMessages?
                .compactMap { .init(fragment: $0.fragments.claimIntentSourceMessageFragment) } ?? []

            if let currentStepFragment = currentStep?.fragments.claimIntentStepFragment {
                return .init(currentStep: .init(fragment: currentStepFragment), id: id, sourceMessages: sourceMessages)
            }
        } catch {
            throw SubmitClaimError.error(message: error.localizedDescription)
        }

        return nil
    }

    func claimIntentSubmitTask(stepId: String) async throws -> ClaimIntent? {
        let input = OctopusGraphQL.ClaimIntentSubmitTaskInput(stepId: stepId)
        let mutation = OctopusGraphQL.ClaimIntentSubmitTaskMutation(input: input)

        do {
            let data = try await octopus.client.mutation(mutation: mutation)
            if let userError = data?.claimIntentSubmitTask.userError, let message = userError.message {
                throw SubmitClaimError.error(message: message)
            }

            let currentStep = data?.claimIntentSubmitTask.intent?.currentStep
            let id = data?.claimIntentSubmitTask.intent?.id ?? ""
            let sourceMessages: [SourceMessage] =
                data?.claimIntentSubmitTask.intent?.sourceMessages?
                .compactMap { .init(fragment: $0.fragments.claimIntentSourceMessageFragment) } ?? []

            currentStep?.content.asClaimIntentStepContentForm?.fields
                .forEach { field in
                    let defaultValue = field.defaultValue
                    print("defaultValue: \(defaultValue ?? "nil")")
                }

            if let currentStepFragment = currentStep?.fragments.claimIntentStepFragment {
                return .init(currentStep: .init(fragment: currentStepFragment), id: id, sourceMessages: sourceMessages)
            }
        } catch {
            throw SubmitClaimError.error(message: error.localizedDescription)
        }

        return nil
    }

    func claimIntentSkipStep(stepId: String) async throws -> ClaimIntent? {
        let mutation = OctopusGraphQL.ClaimIntentSkipStepMutation(stepId: stepId)

        do {
            let data = try await octopus.client.mutation(mutation: mutation)
            if let userError = data?.claimIntentSkipStep.userError, let message = userError.message {
                throw SubmitClaimError.error(message: message)
            }

            let currentStep = data?.claimIntentSkipStep.intent?.currentStep
            let id = data?.claimIntentSkipStep.intent?.id ?? ""
            let sourceMessages: [SourceMessage] =
                data?.claimIntentSkipStep.intent?.sourceMessages?
                .compactMap { .init(fragment: $0.fragments.claimIntentSourceMessageFragment) } ?? []

            if let currentStepFragment = currentStep?.fragments.claimIntentStepFragment {
                return .init(currentStep: .init(fragment: currentStepFragment), id: id, sourceMessages: sourceMessages)
            }
        } catch {
            throw SubmitClaimError.error(message: error.localizedDescription)
        }

        return nil
    }

    func getNextStep(claimIntentId: String) async throws -> ClaimIntent {
        let query = OctopusGraphQL.ClaimIntentQuery(claimIntentId: claimIntentId)

        do {
            let data = try await octopus.client.fetch(query: query)
            let sourceMessages: [SourceMessage] =
                data.claimIntent.sourceMessages?
                .compactMap { .init(fragment: $0.fragments.claimIntentSourceMessageFragment) } ?? []

            let currentStepFragment = data.claimIntent.currentStep.fragments.claimIntentStepFragment
            return .init(
                currentStep: .init(fragment: currentStepFragment),
                id: data.claimIntent.id,
                sourceMessages: sourceMessages
            )
        } catch {
            throw SubmitClaimError.error(message: error.localizedDescription)
        }
    }

    func claimIntentSubmitSelect(stepId: String, selectedValue: String) async throws -> ClaimIntent? {
        let input = OctopusGraphQL.ClaimIntentSubmitSelectInput(stepId: stepId, selectedId: selectedValue)
        let mutation = OctopusGraphQL.ClaimIntentSubmitSelectMutation(input: input)

        do {
            let data = try await octopus.client.mutation(mutation: mutation)
            if let userError = data?.claimIntentSubmitSelect.userError, let message = userError.message {
                throw SubmitClaimError.error(message: message)
            }

            let currentStep = data?.claimIntentSubmitSelect.intent?.currentStep
            let id = data?.claimIntentSubmitSelect.intent?.id ?? ""
            let sourceMessages: [SourceMessage] =
                data?.claimIntentSubmitSelect.intent?.sourceMessages?
                .compactMap { .init(fragment: $0.fragments.claimIntentSourceMessageFragment) } ?? []

            currentStep?.content.asClaimIntentStepContentForm?.fields
                .forEach { field in
                    let defaultValue = field.defaultValue
                    print("defaultValue: \(defaultValue ?? "nil")")
                }

            if let currentStepFragment = currentStep?.fragments.claimIntentStepFragment {
                return .init(currentStep: .init(fragment: currentStepFragment), id: id, sourceMessages: sourceMessages)
            }
        } catch {
            throw SubmitClaimError.error(message: error.localizedDescription)
        }

        return nil
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
            self = .audioRecording(
                model: .init(
                    hint: audioRecording.hint,
                    uploadURI: audioRecording.uploadUri
                )
            )
        } else if let summary = fragment.asClaimIntentStepContentSummary {
            self = .summary(
                model: .init(
                    audioRecordings: summary.audioRecordings.map { .init(url: URL(string: $0.url)!) },
                    fileUploads: summary.fileUploads.map { .init(url: URL(string: $0.url)!) },
                    items: summary.items.map { .init(title: $0.title, value: $0.value) }
                )
            )
        } else if let outcome = fragment.asClaimIntentStepContentOutcome {
            self = .outcome(model: .init(claimId: outcome.claimId))
        } else if let singleStep = fragment.asClaimIntentStepContentSelect {
            self = .singleSelect(model: singleStep.options.compactMap({ .init(id: $0.id, title: $0.title) }))
        } else if let fileUpload = fragment.asClaimIntentStepContentFileUpload {
            self = .fileUpload(
                model: .init(
                    uploadURI: fileUpload.uploadUri
                )
            )
        } else {
            self = .unknown
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

extension SourceMessage {
    init(
        fragment: OctopusGraphQL.ClaimIntentSourceMessageFragment
    ) {
        self.init(
            id: fragment.id,
            text: fragment.text
        )
    }
}

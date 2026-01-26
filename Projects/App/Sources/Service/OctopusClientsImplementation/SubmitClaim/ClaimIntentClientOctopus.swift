import Claims
import Foundation
import SubmitClaimChat
import hCore
import hGraphQL

class ClaimIntentClientOctopus: ClaimIntentClient {
    @Inject private var octopus: hOctopus

    func startClaimIntent(input: StartClaimInput) async throws -> ClaimIntentType? {
        let mutation = OctopusGraphQL.ClaimIntentStartMutation(input: GraphQLNullable(.init()))

        do {
            let data = try await octopus.client.mutation(mutation: mutation)

            let intent = data?.claimIntentStart
            return handleStep(intentFragment: intent?.fragments.claimIntentFragment)
        } catch {
            throw try logClaimIntentError(error)
        }
    }

    func claimIntentSubmitAudio(fileId: String?, freeText: String?, stepId: String) async throws -> ClaimIntentType? {
        let input = OctopusGraphQL.ClaimIntentSubmitAudioInput(
            stepId: stepId,
            audioFileId: GraphQLNullable(optionalValue: fileId),
            freeText: GraphQLNullable(optionalValue: freeText)
        )

        let mutation = OctopusGraphQL.ClaimIntentSubmitAudioMutation(input: input)

        do {
            let data = try await octopus.client.mutation(mutation: mutation)

            if let userError = data?.claimIntentSubmitAudio.userError, let message = userError.message {
                throw ClaimIntentError.error(message: message)
            }

            let intent = data?.claimIntentSubmitAudio.intent
            return handleStep(intentFragment: intent?.fragments.claimIntentFragment)
        } catch {
            throw try logClaimIntentError(error)
        }
    }

    func claimIntentSubmitFile(stepId: String, fileIds: [String]) async throws -> ClaimIntentType? {
        let input = OctopusGraphQL.ClaimIntentSubmitFileUploadInput(
            stepId: stepId,
            fileIds: fileIds
        )

        let mutation = OctopusGraphQL.ClaimIntentSubmitFileUploadMutation(input: input)
        do {
            let data = try await octopus.client.mutation(mutation: mutation)

            if let userError = data?.claimIntentSubmitFileUpload.userError, let message = userError.message {
                throw ClaimIntentError.error(message: message)
            }

            let intent = data?.claimIntentSubmitFileUpload.intent
            return handleStep(intentFragment: intent?.fragments.claimIntentFragment)
        } catch {
            throw try logClaimIntentError(error)
        }
    }

    func claimIntentSubmitForm(
        fields: [FieldValue],
        stepId: String
    ) async throws -> ClaimIntentType? {
        let fieldInput: [OctopusGraphQL.ClaimIntentFormSubmitInputField] = fields.map {
            .init(fieldId: $0.id, values: $0.values)
        }
        let input = OctopusGraphQL.ClaimIntentSubmitFormInput(stepId: stepId, fields: fieldInput)
        let mutation = OctopusGraphQL.ClaimIntentSubmitFormMutation(input: input)

        do {
            let data = try await octopus.client.mutation(mutation: mutation)
            if let userError = data?.claimIntentSubmitForm.userError, let message = userError.message {
                throw ClaimIntentError.error(message: message)
            }

            let intent = data?.claimIntentSubmitForm.intent
            return handleStep(intentFragment: intent?.fragments.claimIntentFragment)
        } catch {
            throw try logClaimIntentError(error)
        }
    }

    func claimIntentSubmitSummary(stepId: String) async throws -> ClaimIntentType? {
        let input = OctopusGraphQL.ClaimIntentSubmitSummaryInput(stepId: stepId)
        let mutation = OctopusGraphQL.ClaimIntentSubmitSummaryMutation(input: input)

        do {
            let data = try await octopus.client.mutation(mutation: mutation)
            if let userError = data?.claimIntentSubmitSummary.userError, let message = userError.message {
                throw ClaimIntentError.error(message: message)
            }

            let intent = data?.claimIntentSubmitSummary.intent
            return handleStep(intentFragment: intent?.fragments.claimIntentFragment)
        } catch {
            throw ClaimIntentError.error(message: error.localizedDescription)
        }
    }

    func handleStep(
        intentFragment: OctopusGraphQL.ClaimIntentFragment?
    ) -> ClaimIntentType? {
        if let trackingId = intentFragment?.currentStep?.content.__typename {
            log.addUserAction(
                type: .custom,
                name: trackingId,
                error: nil,
                attributes: nil
            )
        }

        let id = intentFragment?.id ?? ""
        let outcome: ClaimIntentStepOutcome? =
            .init(fragment: intentFragment?.createdClaim)

        let isSkippable =
            intentFragment?.currentStep?.fragments.claimIntentStepFragment.content.fragments
            .claimIntentStepContentFragment.extractIsSkippable() ?? false
        let isRegrettable =
            intentFragment?.currentStep?.isRegrettable ?? false

        if let currentStepFragment = intentFragment?.currentStep?.fragments.claimIntentStepFragment {
            return .intent(
                model: .init(
                    currentStep: .init(fragment: currentStepFragment),
                    id: id,
                    isSkippable: isSkippable,
                    isRegrettable: isRegrettable,
                    progress: intentFragment?.progress ?? 0,
                    hint: intentFragment?.currentStep?.hint
                )
            )
        } else if let outcome {
            return .outcome(
                model: outcome
            )
        }
        return nil
    }

    func claimIntentSubmitTask(stepId: String) async throws -> ClaimIntentType? {
        let input = OctopusGraphQL.ClaimIntentSubmitTaskInput(stepId: stepId)
        let mutation = OctopusGraphQL.ClaimIntentSubmitTaskMutation(input: input)

        do {
            let data = try await octopus.client.mutation(mutation: mutation)
            if let userError = data?.claimIntentSubmitTask.userError, let message = userError.message {
                throw ClaimIntentError.error(message: message)
            }

            let intent = data?.claimIntentSubmitTask.intent
            return handleStep(intentFragment: intent?.fragments.claimIntentFragment)
        } catch {
            throw try logClaimIntentError(error)
        }
    }

    func claimIntentSkipStep(stepId: String) async throws -> ClaimIntentType? {
        let mutation = OctopusGraphQL.ClaimIntentSkipStepMutation(stepId: stepId)

        do {
            let data = try await octopus.client.mutation(mutation: mutation)
            if let userError = data?.claimIntentSkipStep.userError, let message = userError.message {
                throw ClaimIntentError.error(message: message)
            }

            let intent = data?.claimIntentSkipStep.intent
            return handleStep(intentFragment: intent?.fragments.claimIntentFragment)
        } catch {
            throw try logClaimIntentError(error)
        }
    }

    func claimIntentRegretStep(stepId: String) async throws -> ClaimIntentType? {
        let mutation = OctopusGraphQL.ClaimIntentRegretStepMutation(stepId: stepId)

        do {
            let data = try await octopus.client.mutation(mutation: mutation)
            if let userError = data?.claimIntentRegretStep.userError, let message = userError.message {
                throw ClaimIntentError.error(message: message)
            }

            let intent = data?.claimIntentRegretStep.intent
            return handleStep(intentFragment: intent?.fragments.claimIntentFragment)
        } catch {
            throw try logClaimIntentError(error)
        }
    }

    func getNextStep(claimIntentId: String) async throws -> ClaimIntentType? {
        let query = OctopusGraphQL.ClaimIntentQuery(claimIntentId: claimIntentId)

        do {
            let data = try await octopus.client.fetch(query: query)
            let intent = data.claimIntent
            return handleStep(intentFragment: intent.fragments.claimIntentFragment)
        } catch {
            throw try logClaimIntentError(error)
        }
    }

    func claimIntentSubmitSelect(stepId: String, selectedValue: String) async throws -> ClaimIntentType? {
        let input = OctopusGraphQL.ClaimIntentSubmitSelectInput(stepId: stepId, selectedId: selectedValue)
        let mutation = OctopusGraphQL.ClaimIntentSubmitSelectMutation(input: input)

        do {
            let data = try await octopus.client.mutation(mutation: mutation)
            if let userError = data?.claimIntentSubmitSelect.userError, let message = userError.message {
                throw ClaimIntentError.error(message: message)
            }

            let intent = data?.claimIntentSubmitSelect.intent
            return handleStep(intentFragment: intent?.fragments.claimIntentFragment)
        } catch {
            throw try logClaimIntentError(error)
        }
    }

    func logClaimIntentError(_ error: Error) throws -> Error {
        log.addUserAction(
            type: .custom,
            name: "ClaimIntentError",
            error: nil,
            attributes: nil
        )
        return ClaimIntentError.error(message: error.localizedDescription)
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
                    uploadURI: audioRecording.uploadUri,
                    freeTextMinLength: audioRecording.freeTextMinLength,
                    freeTextMaxLength: audioRecording.freeTextMaxLength
                )
            )
        } else if let summary = fragment.asClaimIntentStepContentSummary {
            self = .summary(
                model: .init(
                    audioRecordings: summary.audioRecordings.map {
                        .init(url: URL(string: $0.url)!)
                    },
                    fileUploads: summary.fileUploads.map {
                        .init(
                            url: URL(string: $0.url)!,
                            contentType: .findBy(mimeType: $0.contentType),
                            fileName: $0.fileName
                        )
                    },
                    items: summary.items.map {
                        .init(title: $0.title, value: $0.value)
                    },
                    freeTexts: summary.freeTexts
                )
            )
        } else if let singleStep = fragment.asClaimIntentStepContentSelect {
            self = .singleSelect(
                model: .init(
                    defaultSelectedId: singleStep.defaultSelectedId,
                    options: singleStep.options.compactMap({ .init(id: $0.id, title: $0.title) }),
                    style: singleStep.style.asSelectStyle
                )
            )
        } else if let fileUpload = fragment.asClaimIntentStepContentFileUpload {
            self = .fileUpload(
                model: .init(
                    uploadURI: fileUpload.uploadUri
                )
            )
        } else if let deflect = fragment.asClaimIntentStepContentDeflection {
            self = .deflect(
                model:
                    .init(
                        title: deflect.title,
                        content: .init(title: deflect.content.title, description: deflect.content.description),
                        partners: deflect.partners.map {
                            .init(fragment: $0.fragments.claimIntentOutcomeDeflectionPartnerFragment)
                        },
                        infoText: deflect.infoText,
                        warningText: deflect.warningText,
                        questions: deflect.faq.map { .init(question: $0.title, answer: $0.description) },
                        linkOnlyPartners: deflect.simplePartners.map({
                            .init(url: $0.url, buttonText: $0.urlButtonTitle)
                        }),
                        buttonTitle: deflect.buttonTitle
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
            defaultValues: fragment.defaultValues,
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
        case .phoneNumber:
            return .phoneNumber
        case .singleSelect:
            return .singleSelect
        case .binary:
            return .binary
        case .multiSelect:
            return .multiSelect
        }
    }
}

extension GraphQLEnum<OctopusGraphQL.ClaimIntentStepContentSelectStyle> {
    public var asSelectStyle: ClaimIntentStepContentSelect.ClaimIntentStepContentSelectStyle {
        switch self {
        case .case(let style):
            switch style {
            case .pill:
                return .pill
            case .binary:
                return .binary
            }
        case .unknown:
            return .pill
        }
    }
}

extension OctopusGraphQL.ClaimIntentStepContentFragment {
    func extractIsSkippable() -> Bool {
        if let form = asClaimIntentStepContentForm {
            return form.isSkippable
        } else if let audioRecording = asClaimIntentStepContentAudioRecording {
            return audioRecording.isSkippable
        } else if let fileUpload = asClaimIntentStepContentFileUpload {
            return fileUpload.isSkippable
        } else if let select = asClaimIntentStepContentSelect {
            return select.isSkippable
        }
        return false
    }
}

@MainActor
extension ClaimIntentStepOutcome {
    init?(
        fragment: OctopusGraphQL.ClaimIntentFragment.CreatedClaim?
    ) {
        guard let fragment else { return nil }

        self = .claim(
            model: .init(claimId: fragment.id, claim: .init(claim: fragment.fragments.claimFragment))
        )
    }
}

extension Partner {
    init(fragment: OctopusGraphQL.ClaimIntentOutcomeDeflectionPartnerFragment) {
        self.init(
            id: fragment.id,
            imageUrl: fragment.imageUrl,
            url: fragment.url,
            phoneNumber: fragment.phoneNumber,
            title: fragment.title,
            description: fragment.description,
            info: fragment.info,
            buttonText: fragment.urlButtonTitle,
            preferredImageHeight: nil
        )
    }
}

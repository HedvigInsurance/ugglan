import SwiftUI
import hCoreUI

final class SubmitClaimFormStep: @MainActor ClaimIntentStepHandler {
    var id: String { claimIntent.id }
    let claimIntent: ClaimIntent
    let sender: SubmitClaimChatMesageSender
    @Published var isLoading: Bool = false
    @Published var isEnabled: Bool = true
    @Published var isDatePickerPresented: DatePickerViewModel?
    @Published var isSelectItemPresented: SingleItemModel?

    let formModel: ClaimIntentStepContentForm
    private let service: ClaimIntentService

    @Published var dateForPicker: Date = Date()
    @Published var formValues: [String: FormStepValue] = [:]
    required init(claimIntent: ClaimIntent, sender: SubmitClaimChatMesageSender, service: ClaimIntentService) {
        self.claimIntent = claimIntent
        self.sender = sender
        self.service = service
        guard case .form(let model) = claimIntent.currentStep.content else {
            fatalError("FormStepHandler initialized with non-form content")
        }
        self.formModel = model
        self.initializeFormValues()
    }

    private func initializeFormValues() {
        for field in formModel.fields {
            if let defaultValue = field.defaultValue {
                formValues[field.id] = .init(value: defaultValue)
            } else {
                formValues[field.id] = .init(value: "")
            }
        }
    }

    func getFormStepValue(for fieldId: String) -> FormStepValue {
        formValues[fieldId]!
    }

    func validateInput() -> Bool {
        // Validate required fields
        for field in formModel.fields where field.isRequired {
            guard let value = formValues[field.id], !value.value.isEmpty else {
                return false
            }
        }
        return true
    }

    func submitResponse() async throws -> ClaimIntent {
        guard validateInput() else {
            throw ClaimIntentError.invalidInput
        }

        isLoading = true
        defer { isLoading = false }

        let fieldValues = formValues.map { FieldValue(id: $0.key, values: [$0.value.value]) }

        guard
            let result = try await service.claimIntentSubmitForm(
                fields: fieldValues,
                stepId: claimIntent.currentStep.id
            )
        else {
            throw ClaimIntentError.invalidResponse
        }
        return result
    }
}

final class FormStepValue: ObservableObject {
    @Published var value: String = ""

    init(value: String) {
        self.value = value
    }
}

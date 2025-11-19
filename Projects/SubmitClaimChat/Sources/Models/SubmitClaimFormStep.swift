import SwiftUI
import hCoreUI

final class SubmitClaimFormStep: ClaimIntentStepHandler {
    @Published var isDatePickerPresented: DatePickerViewModel?
    @Published var isSelectItemPresented: SingleItemModel?
    @Published var dateForPicker: Date = Date()
    @Published var formValues: [String: FormStepValue] = [:]

    let formModel: ClaimIntentStepContentForm
    required init(claimIntent: ClaimIntent, service: ClaimIntentService, mainHandler: @escaping (ClaimIntent) -> Void) {
        guard case .form(let model) = claimIntent.currentStep.content else {
            fatalError("FormStepHandler initialized with non-form content")
        }
        self.formModel = model
        super.init(claimIntent: claimIntent, service: service, mainHandler: mainHandler)
        self.initializeFormValues()
    }

    private func initializeFormValues() {
        for field in formModel.fields {
            formValues[field.id] = .init(values: field.defaultValues)
        }
    }

    func getFormStepValue(for fieldId: String) -> FormStepValue {
        formValues[fieldId]!
    }

    override func validateInput() -> Bool {
        // Validate required fields
        for field in formModel.fields where field.isRequired {
            guard let value = formValues[field.id], !value.values.isEmpty else {
                return false
            }
        }
        return true
    }

    override func submitResponse() async throws -> ClaimIntent {
        guard validateInput() else {
            throw ClaimIntentError.invalidInput
        }

        withAnimation {
            isLoading = true
        }
        defer {
            withAnimation {
                isLoading = false
            }
        }

        let fieldValues = formValues.map { FieldValue(id: $0.key, values: $0.value.values) }

        guard
            let result = try await service.claimIntentSubmitForm(
                fields: fieldValues,
                stepId: claimIntent.currentStep.id
            )
        else {
            throw ClaimIntentError.invalidResponse
        }
        mainHandler(result)
        withAnimation {
            isEnabled = false
        }
        return result
    }
}

final class FormStepValue: ObservableObject {
    @Published var values: [String] = []
    @Published var value: String = "" {
        didSet {
            values = [value]
        }
    }
    init(values: [String]) {
        self.value = values.first ?? ""
        self.values = values
    }
}

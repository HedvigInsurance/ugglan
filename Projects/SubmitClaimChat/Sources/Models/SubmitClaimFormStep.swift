import SwiftUI
import hCoreUI

final class SubmitClaimFormStep: ClaimIntentStepHandler {
    @Published var isDatePickerPresented: DatePickerViewModel?
    @Published var isSelectItemPresented: SingleItemModel?
    @Published var dateForPicker: Date = Date()
    @Published var formValues: [String: FormStepValue] = [:]

    let formModel: ClaimIntentStepContentForm
    required init(
        claimIntent: ClaimIntent,
        service: ClaimIntentService,
        mainHandler: @escaping (SubmitClaimEvent) -> Void
    ) {
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
        for field in formModel.fields where field.isRequired {
            guard let fieldModel = formValues[field.id] else { continue }
            fieldModel.validateField(field)
        }
        return formValues.values.allSatisfy({ $0.error == nil })
    }

    override func executeStep() async throws -> ClaimIntentType {
        guard validateInput() else {
            throw ClaimIntentError.invalidInput
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
        return result
    }

    func getAllValuesToShow() -> [(String, String)] {
        formModel.fields
            .map { field in
                let userEnteredValues = formValues[field.id]!.values
                let valuesToDisplay = field.options.filter({ userEnteredValues.contains($0.value) }).map({ $0.title })
                if valuesToDisplay.isEmpty {
                    return (
                        field.title, userEnteredValues.isEmpty ? "Skipped" : userEnteredValues.joined(separator: ", ")
                    )
                }
                return (field.title, valuesToDisplay.joined(separator: ", "))
            }
    }
}

final class FormStepValue: ObservableObject {
    @Published var values: [String] = [] {
        didSet {
            error = nil
        }
    }
    @Published var value: String = "" {
        didSet {
            values = [value]
            error = nil
        }
    }
    @Published var error: String?
    init(values: [String]) {
        self.value = values.first ?? ""
        self.values = values
    }
}

//MARK: VALIDATION
extension FormStepValue {
    fileprivate func validateField(_ field: ClaimIntentStepContentForm.ClaimIntentStepContentFormField) {
        let finalValue = self.values.joined(separator: ",")

        guard !finalValue.isEmpty else {
            self.error = "This field is required"
            return
        }

        let errors = collectValidationErrors(for: field, value: finalValue)
        self.error = errors.isEmpty ? nil : errors.joined(separator: "\n")
    }

    private func collectValidationErrors(
        for field: ClaimIntentStepContentForm.ClaimIntentStepContentFormField,
        value: String
    ) -> [String] {
        switch field.type {
        case .text:
            return validateTextField(value: value, field: field)
        case .number:
            return validateNumberField(value: value, field: field)
        default:
            return []
        }
    }

    private func validateTextField(
        value: String,
        field: ClaimIntentStepContentForm.ClaimIntentStepContentFormField
    ) -> [String] {
        var errors: [String] = []
        if let minValue = field.minValue, value.count < Int(minValue) ?? 0 {
            errors.append("Value must be at least \(minValue) characters long")
        }
        if let maxValue = field.maxValue, value.count > Int(maxValue) ?? 0 {
            errors.append("Value must be at most \(maxValue) characters long")
        }
        return errors
    }

    private func validateNumberField(
        value: String,
        field: ClaimIntentStepContentForm.ClaimIntentStepContentFormField
    ) -> [String] {
        var errors: [String] = []
        guard let numericValue = Int(value) else { return errors }

        if let minValue = field.minValue, let minInt = Int(minValue), numericValue < minInt {
            errors.append("Value must be at least \(minValue)")
        }
        if let maxValue = field.maxValue, let maxInt = Int(maxValue), numericValue > maxInt {
            errors.append("Value must be at most \(maxValue)")
        }
        return errors
    }
}

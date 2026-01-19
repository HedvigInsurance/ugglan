import SwiftUI
import hCore
import hCoreUI

final class SubmitClaimFormStep: ClaimIntentStepHandler {
    @Published var isDatePickerPresented: DatePickerViewModel? {
        willSet {
            UIApplication.dismissKeyboard()
        }
    }
    @Published var isSelectItemPresented: SingleItemModel? {
        willSet {
            UIApplication.dismissKeyboard()
        }
    }
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

    func getAllValuesToShow() -> [ResultDisplayItem] {
        formModel.fields
            .map { field in
                let userEnteredValues = formValues[field.id]!.values
                let valuesToDisplay = field.options.filter({ userEnteredValues.contains($0.value) }).map({ $0.title })
                if !valuesToDisplay.isEmpty {
                    let valueToDisplay = valuesToDisplay.joined(separator: ", ")
                    return .init(key: field.title, value: valueToDisplay, skipped: false)
                }
                let valueToDisplay = userEnteredValues.joined(separator: ", ")
                let isSkipped = userEnteredValues.isEmpty || userEnteredValues.contains(where: { $0 == "" })
                return .init(
                    key: field.title,
                    value: isSkipped ? L10n.claimChatSkippedStep : valueToDisplay,
                    skipped: isSkipped
                )
            }
    }

    struct ResultDisplayItem {
        let key: String
        let value: String
        let skipped: Bool
    }

    override func accessibilityEditHint() -> String {
        if state.isSkipped {
            return L10n.claimChatSkippedLabel
        }
        let items = getAllValuesToShow()
            .filter { !$0.skipped }
            .map { "\($0.key): \($0.value.localDateToDate?.displayDateDDMMMYYYYFormat ?? $0.value)" }
        if items.isEmpty {
            return ""
        }
        return L10n.a11YSubmittedValues(items.count) + ": " + items.joined(separator: ", ")
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
            self.error = L10n.claimChatFormRequiredField
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
        if let minValue = field.minValue, let minValueInt = Int(minValue), value.count < minValueInt {
            errors.append(L10n.claimChatFormTextMinChar(minValueInt))
        }
        if let maxValue = field.maxValue, let maxValueInt = Int(maxValue), value.count > maxValueInt {
            errors.append(L10n.claimChatFormTextMaxChar(maxValueInt))
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
            errors.append(L10n.claimChatFormNumberMinChar(minInt))
        }
        if let maxValue = field.maxValue, let maxInt = Int(maxValue), numericValue > maxInt {
            errors.append(L10n.claimChatFormNumberMaxChar(maxInt))
        }
        return errors
    }
}

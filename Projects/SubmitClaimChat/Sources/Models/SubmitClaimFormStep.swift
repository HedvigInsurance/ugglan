import SwiftUI
import hCore
import hCoreUI

final class SubmitClaimFormStep: ClaimIntentStepHandler {
    @Published var currentFieldId: String?
    @Published var isDatePickerPresented: DatePickerViewModel? {
        willSet {
            UIApplication.dismissKeyboard()
        }
        didSet {
            handleFieldPresentation(dismissed: oldValue?.id)
        }
    }
    @Published var isSelectItemPresented: SingleItemModel? {
        willSet {
            UIApplication.dismissKeyboard()
        }
        didSet {
            handleFieldPresentation(dismissed: oldValue?.id)
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

    /// Handles field presentation dismissal and focuses the field for accessibility after a short delay
    private func handleFieldPresentation(dismissed fieldId: String?) {
        guard let fieldId else { return }
        Task {
            try? await Task.sleep(seconds: ClaimChatConstants.Timing.shortDelay)
            currentFieldId = fieldId
        }
    }

    func getFormStepValue(for fieldId: String) -> FormStepValue {
        guard let value = formValues[fieldId] else {
            fatalError("FormStepValue not found for fieldId: \(fieldId). This indicates a programming error.")
        }
        return value
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
        let values = items.map { "\($0.key): \($0.value.localDateToDate?.displayDateDDMMMYYYYFormat ?? $0.value)" }
        return .accessibilitySubmittedValues(count: items.count, values: values)
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

// MARK: - Validation
extension FormStepValue {
    fileprivate func validateField(_ field: ClaimIntentStepContentForm.ClaimIntentStepContentFormField) {
        self.error = FormFieldValidator.validate(values: values, for: field)
    }
}

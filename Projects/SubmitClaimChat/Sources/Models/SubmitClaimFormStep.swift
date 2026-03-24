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
    @Published var searchFieldPresentation: FormFieldSearchModel? {
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
            formValues[field.id] = .init(field: field)
        }
    }

    /// Handles field presentation dismissal and focuses the field for accessibility after a short delay
    private func handleFieldPresentation(dismissed fieldId: String?) {
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
                // For search fields, use the stored display title
                if field.type == .search, let selectedSearchItem = formValues[field.id]?.selectedSearchItem {
                    return .init(skipped: false, key: field.title, type: .searchResult(value: selectedSearchItem))
                }
                let valuesToDisplay = field.options.filter({ userEnteredValues.contains($0.value) }).map({ $0.title })
                if !valuesToDisplay.isEmpty {
                    let valueToDisplay = valuesToDisplay.joined(separator: ", ")
                    return .init(skipped: false, key: field.title, type: .text(value: valueToDisplay))
                }
                var valueToDisplay = userEnteredValues.joined(separator: ", ")
                if let suffix = field.suffix {
                    valueToDisplay += " \(suffix)"
                }
                let isSkipped = userEnteredValues.isEmpty || userEnteredValues.contains(where: { $0 == "" })
                let value = isSkipped ? L10n.claimChatSkippedStep : valueToDisplay
                return .init(skipped: isSkipped, key: field.title, type: .text(value: value))
            }
    }

    struct ResultDisplayItem {
        let skipped: Bool
        let key: String
        let type: ResultDisplayItemType

        var value: String {
            switch type {
            case let .text(value): return value
            case let .searchResult(item): return item.title
            }
        }
    }

    enum ResultDisplayItemType {
        case text(value: String)
        case searchResult(value: SingleSelectValue)
    }

    override func accessibilityEditHint() -> String {
        if state.isSkipped {
            return L10n.claimChatSkippedStep
        }
        let items = getAllValuesToShow()
            .filter { !$0.skipped }
        let values = items.map {
            "\($0.key): \($0.value.localDateToDate?.displayDateDDMMMYYYYFormat ?? $0.value)"
        }
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
    /// Display title for search-selected values (since the value is an opaque ID)
    @Published var selectedSearchItem: SingleSelectValue? {
        didSet {
            if let selectedSearchItem {
                value = selectedSearchItem.value
            }
        }
    }
    var lastSearchQuery: String?
    init(field: ClaimIntentStepContentForm.ClaimIntentStepContentFormField) {
        self.value = field.defaultValues.first ?? ""
        self.values = field.defaultValues
        self.lastSearchQuery = field.searchData?.suggestedQuery
    }
}

// MARK: - Validation
extension FormStepValue {
    fileprivate func validateField(_ field: ClaimIntentStepContentForm.ClaimIntentStepContentFormField) {
        self.error = FormFieldValidator.validate(values: values, for: field)
    }
}

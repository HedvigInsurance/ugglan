import Observation
import SwiftUI
import hCore
import hCoreUI

final class SubmitClaimFormStep: ClaimIntentStepHandler {
    @ObservationIgnored private var _currentFieldId: String?
    var currentFieldId: String? {
        get {
            observationRegistrar.access(self, keyPath: \SubmitClaimFormStep.currentFieldId)
            return _currentFieldId
        }
        set {
            observationRegistrar.withMutation(of: self, keyPath: \SubmitClaimFormStep.currentFieldId) {
                _currentFieldId = newValue
            }
        }
    }

    @ObservationIgnored private var _isDatePickerPresented: DatePickerViewModel?
    var isDatePickerPresented: DatePickerViewModel? {
        get {
            observationRegistrar.access(self, keyPath: \SubmitClaimFormStep.isDatePickerPresented)
            return _isDatePickerPresented
        }
        set {
            UIApplication.dismissKeyboard()
            let oldValue = _isDatePickerPresented
            observationRegistrar.withMutation(of: self, keyPath: \SubmitClaimFormStep.isDatePickerPresented) {
                _isDatePickerPresented = newValue
            }
            handleFieldPresentation(dismissed: oldValue?.id)
        }
    }

    @ObservationIgnored private var _isSelectItemPresented: SingleItemModel?
    var isSelectItemPresented: SingleItemModel? {
        get {
            observationRegistrar.access(self, keyPath: \SubmitClaimFormStep.isSelectItemPresented)
            return _isSelectItemPresented
        }
        set {
            UIApplication.dismissKeyboard()
            let oldValue = _isSelectItemPresented
            observationRegistrar.withMutation(of: self, keyPath: \SubmitClaimFormStep.isSelectItemPresented) {
                _isSelectItemPresented = newValue
            }
            handleFieldPresentation(dismissed: oldValue?.id)
        }
    }

    @ObservationIgnored private var _searchFieldPresentation: FormFieldSearchModel?
    var searchFieldPresentation: FormFieldSearchModel? {
        get {
            observationRegistrar.access(self, keyPath: \SubmitClaimFormStep.searchFieldPresentation)
            return _searchFieldPresentation
        }
        set {
            UIApplication.dismissKeyboard()
            let oldValue = _searchFieldPresentation
            observationRegistrar.withMutation(of: self, keyPath: \SubmitClaimFormStep.searchFieldPresentation) {
                _searchFieldPresentation = newValue
            }
            handleFieldPresentation(dismissed: oldValue?.id)
        }
    }

    @ObservationIgnored private var _dateForPicker: Date = Date()
    var dateForPicker: Date {
        get {
            observationRegistrar.access(self, keyPath: \SubmitClaimFormStep.dateForPicker)
            return _dateForPicker
        }
        set {
            observationRegistrar.withMutation(of: self, keyPath: \SubmitClaimFormStep.dateForPicker) {
                _dateForPicker = newValue
            }
        }
    }

    @ObservationIgnored private var _formValues: [String: FormStepValue] = [:]
    var formValues: [String: FormStepValue] {
        get {
            observationRegistrar.access(self, keyPath: \SubmitClaimFormStep.formValues)
            return _formValues
        }
        set {
            observationRegistrar.withMutation(of: self, keyPath: \SubmitClaimFormStep.formValues) {
                _formValues = newValue
            }
        }
    }

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
            await delay(ClaimChatConstants.Timing.shortDelay)
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
                let valuesToDisplay = field.options.filter({ userEnteredValues.contains($0.value) })
                    .map({ $0.displayTitle })
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

@Observable
final class FormStepValue {
    var values: [String] = [] {
        didSet {
            error = nil
        }
    }
    var value: String = "" {
        didSet {
            values = [value]
            error = nil
        }
    }
    var error: String?
    /// Display title for search-selected values (since the value is an opaque ID)
    var selectedSearchItem: SingleSelectValue? {
        didSet {
            if let selectedSearchItem {
                value = selectedSearchItem.value
            }
        }
    }
    @ObservationIgnored var lastSearchQuery: String?
    init(field: ClaimIntentStepContentForm.ClaimIntentStepContentFormField) {
        let seedValues = field.currentValues.isEmpty ? field.defaultValues : field.currentValues
        self.value = seedValues.first ?? ""
        self.values = seedValues
        self.lastSearchQuery = field.searchData?.suggestedQuery
    }
}

// MARK: - Validation
extension FormStepValue {
    fileprivate func validateField(_ field: ClaimIntentStepContentForm.ClaimIntentStepContentFormField) {
        self.error = FormFieldValidator.validate(values: values, for: field)
    }
}

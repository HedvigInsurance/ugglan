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
        // Validate required fields
        for field in formModel.fields where field.isRequired {
            if let fieldModel = formValues[field.id] {
                if fieldModel.values.isEmpty {
                    fieldModel.error = "This field is required"
                } else {
                    fieldModel.error = nil
                }
            }
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
                    return (field.title, userEnteredValues.joined(separator: ", "))
                }
                return (field.title, valuesToDisplay.joined(separator: ", "))
            }
            .filter({ !$0.1.isEmpty })
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

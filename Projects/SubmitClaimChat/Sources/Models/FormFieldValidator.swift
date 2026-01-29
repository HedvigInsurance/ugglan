import Foundation
import hCore

/// Validates form field values based on field type and constraints
struct FormFieldValidator {
    typealias FormField = ClaimIntentStepContentForm.ClaimIntentStepContentFormField

    /// Validates a field's values and returns an error message if validation fails
    /// - Parameters:
    ///   - values: The values to validate
    ///   - field: The form field configuration
    /// - Returns: Error message if validation fails, nil if valid
    static func validate(values: [String], for field: FormField) -> String? {
        let finalValue = values.joined(separator: ",")

        guard !finalValue.isEmpty else {
            return L10n.claimChatFormRequiredField
        }

        let errors = collectValidationErrors(for: field, value: finalValue)
        return errors.isEmpty ? nil : errors.joined(separator: "\n")
    }

    private static func collectValidationErrors(for field: FormField, value: String) -> [String] {
        switch field.type {
        case .text:
            return validateTextField(value: value, field: field)
        case .number:
            return validateNumberField(value: value, field: field)
        default:
            return []
        }
    }

    private static func validateTextField(value: String, field: FormField) -> [String] {
        var errors: [String] = []
        if let minValue = field.minValue, let minValueInt = Int(minValue), value.count < minValueInt {
            errors.append(L10n.claimChatFormTextMinChar(minValueInt))
        }
        if let maxValue = field.maxValue, let maxValueInt = Int(maxValue), value.count > maxValueInt {
            errors.append(L10n.claimChatFormTextMaxChar(maxValueInt))
        }
        return errors
    }

    private static func validateNumberField(value: String, field: FormField) -> [String] {
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

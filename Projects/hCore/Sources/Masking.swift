import Flow
import Foundation
import SwiftUI
import UIKit

public enum MaskType: String {
    case none = "None"
    case personalNumber = "PersonalNumber"
    case norwegianPersonalNumber = "NorwegianPersonalNumber"
    case danishPersonalNumber = "DanishPersonalNumber"
    case postalCode = "PostalCode"
    case email = "Email"
    case birthDate = "BirthDate"
    case birthDateReverse = "BirthDateReverse"
    case norwegianPostalCode = "NorwegianPostalCode"
    case digits = "Digits"
}

public struct Masking {
    public let type: MaskType

    @ReadWriteState private var previousText = ""

    public init(type: MaskType) { self.type = type }

    public func applySettings(_ textField: UITextField) {
        textField.keyboardType = keyboardType
        textField.textContentType = textContentType
        textField.autocapitalizationType = autocapitalizationType
    }

    public func isValidSignal(_ textField: UITextField) -> ReadSignal<Bool> {
        textField.distinct().map { text in isValid(text: text) }
    }

    public func applyMasking(_ textField: UITextField) -> Disposable {
        let bag = DisposeBag()

        bag += textField.distinct()
            .onValue { text in
                let newValue = maskValue(text: text, previousText: previousText)
                    .replacingOccurrences(of: " ", with: "\u{00a0}")
                $previousText.value = newValue
                textField.text = newValue
            }

        return bag
    }

    public func isValid(text: String) -> Bool {
        switch type {
        case .norwegianPersonalNumber: return text.count == 11
        case .danishPersonalNumber: return text.count == 11
        case .personalNumber:
            let age = calculateAge(from: text) ?? 0
            return text.count > 10 && 15...130 ~= age
        case .birthDate, .birthDateReverse:
            let age = calculateAge(from: text) ?? 0
            return 15...130 ~= age
        case .email:
            let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
            return emailPredicate.evaluate(with: text)
        case .norwegianPostalCode: return text.count == 4
        case .postalCode: return unmask(text: text).count == 5
        case .digits: return CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: text))
        case .none: return true
        }
    }

    private func unmask(text: String) -> String {
        switch type {
        case .personalNumber: return text.replacingOccurrences(of: "-", with: "")
        case .postalCode: return text.replacingOccurrences(of: "\\s", with: "", options: .regularExpression)
        case .birthDate: return text
        case .birthDateReverse:
            let reverseDateFormatter = DateFormatter()
            reverseDateFormatter.dateFormat = "dd-MM-yyyy"

            guard let date = reverseDateFormatter.date(from: text) else { return text }

            let birthDateFormatter = DateFormatter()
            birthDateFormatter.dateFormat = "yyyy-MM-dd"

            return birthDateFormatter.string(from: date)
        case .email, .norwegianPostalCode, .digits, .norwegianPersonalNumber: return text
        case .danishPersonalNumber: return text.replacingOccurrences(of: "-", with: "")
        case .none: return text
        }
    }

    public func unmaskedValue(text: String) -> String {
        unmask(text: text).replacingOccurrences(of: "\u{00a0}", with: " ")
    }

    public func equalUnmasked(lhs: String, rhs: String) -> Bool {
        let cleanedLhs = unmask(text: lhs).replacingOccurrences(of: "\u{00a0}", with: " ")
        let cleanedRhs = unmask(text: rhs).replacingOccurrences(of: "\u{00a0}", with: " ")
        return cleanedLhs == cleanedRhs
    }

    public func calculateAge(from text: String) -> Int? {
        func calculate(_ format: String, value: String) -> Int? {
            if value.isEmpty { return nil }

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = format

            guard let dateOfBirth = dateFormatter.date(from: value) else { return nil }

            let components = Calendar.current.dateComponents([.year], from: dateOfBirth, to: Date())

            guard let age = components.year else { return nil }

            return age
        }

        let unmaskedValue = self.unmaskedValue(text: text)

        switch type {
        case .danishPersonalNumber, .norwegianPersonalNumber: return nil
        case .personalNumber:
            if let age = calculate("yyMMdd", value: String(unmaskedValue.prefix(6))) { return age }

            if let age = calculate("yyyyMMdd", value: String(unmaskedValue.prefix(8))) { return age }

            return nil
        case .birthDateReverse, .birthDate:
            guard let age = calculate("yyyy-MM-dd", value: unmaskedValue) else { return nil }

            return age
        default: return nil
        }
    }

    public func derivedValues(text: String) -> [String: String]? {
        guard let age = calculateAge(from: text) else { return nil }

        return [".Age": String(age)]
    }

    public var keyboardType: UIKeyboardType {
        switch type {
        case .birthDate, .birthDateReverse, .personalNumber, .norwegianPostalCode, .postalCode, .digits,
            .norwegianPersonalNumber, .danishPersonalNumber:
            return .numberPad
        case .email: return .emailAddress
        case .none: return .default
        }
    }

    public var textContentType: UITextContentType? {
        switch type {
        case .email: return .emailAddress
        default: return nil
        }
    }

    public var autocapitalizationType: UITextAutocapitalizationType {
        switch type {
        case .email: return .none
        default: return .words
        }
    }

    public var placeholderText: String? {
        switch type {
        case .none:
            return nil
        case .personalNumber:
            return L10n.InsurelySeSsn.assistiveText
        case .norwegianPersonalNumber:
            return L10n.SimpleSignLogin.TextField.helperText
        case .danishPersonalNumber:
            return L10n.SimpleSignLogin.TextField.helperTextDk
        case .postalCode:
            return nil
        case .email:
            return L10n.emailPlaceholder
        case .birthDate:
            return nil
        case .birthDateReverse:
            return nil
        case .norwegianPostalCode:
            return nil
        case .digits:
            return nil
        }
    }

    public var helperText: String? {
        switch type {
        case .none:
            return nil
        case .personalNumber:
            return nil
        case .norwegianPersonalNumber:
            return L10n.SimpleSignLogin.TextField.label
        case .danishPersonalNumber:
            return L10n.SimpleSignLogin.TextField.labelDk
        case .postalCode:
            return nil
        case .email:
            return L10n.emailRowTitle
        case .birthDate:
            return nil
        case .birthDateReverse:
            return nil
        case .norwegianPostalCode:
            return nil
        case .digits:
            return nil
        }
    }

    public func maskValue(text: String, previousText: String) -> String {
        func delimitedDigits(delimiterPositions: [Int], maxCount: Int, delimiter: Character) -> String {
            if text.count < previousText.count {
                if text.last == delimiter { return String(text.dropLast(1)) }

                return text
            }

            if text.count <= maxCount {
                var sanitizedText = String(
                    text.filter { $0.isDigit || $0 == delimiter }.enumerated()
                        .filter { index, char in
                            char == delimiter
                                ? delimiterPositions.contains(index + 1) : true
                        }
                        .map { _, char in char }
                )

                delimiterPositions.map { $0 - 1 }.filter { sanitizedText.count > $0 }
                    .filter { Array(sanitizedText)[$0] != delimiter }
                    .forEach { index in
                        sanitizedText.insert(
                            delimiter,
                            at: sanitizedText.index(
                                sanitizedText.startIndex,
                                offsetBy: index
                            )
                        )
                    }

                return sanitizedText
            }

            return previousText
        }

        switch type {
        case .personalNumber:
            if text.count > 11, text.prefix(2) == "19" || text.prefix(2) == "20" {
                return delimitedDigits(delimiterPositions: [9], maxCount: 13, delimiter: "-")
            }

            return delimitedDigits(delimiterPositions: [7], maxCount: 11, delimiter: "-")
        case .postalCode: return delimitedDigits(delimiterPositions: [4], maxCount: 6, delimiter: " ")
        case .norwegianPostalCode: return delimitedDigits(delimiterPositions: [], maxCount: 4, delimiter: " ")
        case .birthDate: return delimitedDigits(delimiterPositions: [5, 8], maxCount: 10, delimiter: "-")
        case .birthDateReverse:
            return delimitedDigits(delimiterPositions: [3, 6], maxCount: 10, delimiter: "-")
        case .digits: return text.filter { $0.isDigit }
        case .email: return text
        case .norwegianPersonalNumber:
            return delimitedDigits(delimiterPositions: [], maxCount: 11, delimiter: " ")
        case .danishPersonalNumber:
            return delimitedDigits(delimiterPositions: [7], maxCount: 11, delimiter: "-")
        case .none: return text
        }
    }
}

extension Masking: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .keyboardType(keyboardType)
            .textContentType(textContentType)
            .autocapitalization(autocapitalizationType)
            .disableAutocorrection(type != .none)
    }
}

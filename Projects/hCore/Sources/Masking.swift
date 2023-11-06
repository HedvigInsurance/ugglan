import Flow
import Foundation
import Introspect
import SwiftUI
import UIKit

public enum MaskType: String {
    case none = "None"
    case disabledSuggestion = "DisabledSuggestion"
    case personalNumber = "PersonalNumber"
    case personalNumber12Digits = "PersonalNumber12Digits"
    case norwegianPersonalNumber = "NorwegianPersonalNumber"
    case danishPersonalNumber = "DanishPersonalNumber"
    case postalCode = "PostalCode"
    case address = "Address"
    case email = "Email"
    case birthDate = "BirthDate"
    case birthDateReverse = "BirthDateReverse"
    case birthDateYYMMDD = "BirthDateYYMMDD"
    case norwegianPostalCode = "NorwegianPostalCode"
    case digits = "Digits"
    case euroBonus = "EuroBonus"
    case fullName = "FullName"
    case firstName = "FirstName"
    case lastName = "LastName"
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
        case .personalNumber12Digits:
            let age = calculateAge(from: text) ?? 0
            return text.count > 12 && 0...130 ~= age
        case .birthDate, .birthDateReverse:
            let age = calculateAge(from: text) ?? 0
            return 15...130 ~= age
        case .birthDateYYMMDD:
            let age = calculateAge(from: text) ?? 0
            return 15...130 ~= age && text.count == 6
        case .email:
            let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
            return emailPredicate.evaluate(with: text)
        case .norwegianPostalCode: return text.count == 4
        case .postalCode: return unmask(text: text).count == 5
        case .address:
            let addressRegEx = "[(A-Z|Å|Ä|Ö)a-zåäö]+(\\s*)+[0-9]*"
            let addressPredicate = NSPredicate(format: "SELF MATCHES %@", addressRegEx)
            return addressPredicate.evaluate(with: text)
        case .digits: return CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: text))
        case .none: return true
        case .disabledSuggestion: return true
        case .euroBonus: return text.count > 3
        case .fullName:
            let fullNameRegex = "^[a-zA-Z]+(?:[\\s.]+[a-zA-Z]+)*$"
            let fullNamePredicate = NSPredicate(format: "SELF MATCHES %@", fullNameRegex)
            return fullNamePredicate.evaluate(with: text)
        case .firstName, .lastName:
            let nameRegEx = "[(A-Z|Å|Ä|Ö)a-zåäö\\s]*"
            let namePredicate = NSPredicate(format: "SELF MATCHES %@", nameRegEx)
            return text.count > 0 && namePredicate.evaluate(with: text)
        }
    }

    private func unmask(text: String) -> String {
        switch type {
        case .personalNumber, .personalNumber12Digits: return text.replacingOccurrences(of: "-", with: "")
        case .postalCode: return text.replacingOccurrences(of: "\\s", with: "", options: .regularExpression)
        case .birthDate: return text
        case .birthDateReverse:
            let reverseDateFormatter = DateFormatter()
            reverseDateFormatter.dateFormat = "dd-MM-yyyy"

            guard let date = reverseDateFormatter.date(from: text) else { return text }
            return date.localDateString
        case .email, .norwegianPostalCode, .digits, .norwegianPersonalNumber: return text
        case .danishPersonalNumber: return text.replacingOccurrences(of: "-", with: "")
        case .none: return text
        case .address: return text.replacingOccurrences(of: "\\s", with: "", options: .regularExpression)
        case .disabledSuggestion: return text
        case .euroBonus: return text.replacingOccurrences(of: "-", with: "")
        case .fullName: return text
        case .birthDateYYMMDD:
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyddMM"
            guard let date = dateFormatter.date(from: text) else { return text }
            return date.localDateString
        case .firstName, .lastName: return text
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
        case .birthDateYYMMDD:
            if let age = calculate("yyMMdd", value: String(unmaskedValue.prefix(6))) { return age }
            return nil
        default: return nil
        }
    }

    public func derivedValues(text: String) -> [String: String]? {
        guard let age = calculateAge(from: text) else { return nil }

        return [".Age": String(age)]
    }

    public var keyboardType: UIKeyboardType {
        switch type {
        case .birthDate, .birthDateReverse, .personalNumber, .personalNumber12Digits, .norwegianPostalCode,
            .postalCode, .digits,
            .norwegianPersonalNumber, .danishPersonalNumber, .fullName, .birthDateYYMMDD:
            return .numberPad
        case .email: return .emailAddress
        case .none: return .default
        case .address: return .default
        case .disabledSuggestion: return .default
        case .euroBonus: return .default
        case .firstName, .lastName: return .default
        }
    }

    public var textContentType: UITextContentType? {
        switch type {
        case .email: return .emailAddress
        case .address: return .streetAddressLine1
        case .disabledSuggestion: return .oneTimeCode
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
        case .personalNumber, .personalNumber12Digits:
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
        case .address:
            return L10n.changeAddressNewAddressLabel
        case .disabledSuggestion:
            return nil
        case .euroBonus:
            return nil
        case .fullName:
            return L10n.TravelCertificate.fullNameLabel
        case .birthDateYYMMDD:
            return L10n.contractBirthdate
        case .firstName:
            return L10n.contractFirstName
        case .lastName:
            return L10n.contractLastName
        }
    }

    public var helperText: String? {
        switch type {
        case .none:
            return nil
        case .personalNumber, .personalNumber12Digits:
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
        case .address:
            return nil
        case .disabledSuggestion:
            return nil
        case .euroBonus:
            return nil
        case .fullName:
            return nil
        case .birthDateYYMMDD:
            return nil
        case .firstName, .lastName: return nil
        }
    }

    public var disableAutocorrection: Bool {
        switch type {
        case .none, .disabledSuggestion:
            return true
        default: return false
        }
    }
    public var spellCheckingType: UITextSpellCheckingType {
        switch type {
        case .none, .disabledSuggestion:
            return .no
        default: return .yes
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

        func uppercasedAlphaNumeric(maxCount: Int) -> String {
            if text.count < previousText.count {
                return text
            }

            if text.count <= maxCount {
                let sanitizedText = String(
                    text.filter { $0.isNumber || $0.isLetter }.enumerated()
                        .map { _, char in char }
                )
                return sanitizedText.uppercased()
            }

            return previousText
        }

        func isDigit(maxCount: Int) -> String {
            if text.count < previousText.count {
                return text
            }

            if text.count <= maxCount {
                let sanitizedText = String(text.filter { $0.isDigit })
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
        case .personalNumber12Digits:
            if text.count > 11, text.prefix(2) == "19" || text.prefix(2) == "20" {
                return delimitedDigits(delimiterPositions: [9], maxCount: 13, delimiter: "-")
            }
            return text
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
        case .address: return text
        case .disabledSuggestion: return text
        case .euroBonus:
            return uppercasedAlphaNumeric(maxCount: 12)
        case .fullName: return text
        case .birthDateYYMMDD:
            return isDigit(maxCount: 6)
        case .firstName, .lastName: return text
        }
    }
}

extension Masking: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .keyboardType(keyboardType)
            .textContentType(textContentType)
            .autocapitalization(autocapitalizationType)
            .disableAutocorrection(disableAutocorrection)
            .autocorrectionDisabled()
            .introspectTextField { textField in
                textField.spellCheckingType = spellCheckingType
            }
    }
}

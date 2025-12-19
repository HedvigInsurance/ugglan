import Foundation
import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect

public enum MaskType {
    case none
    case disabledSuggestion
    case personalNumber(minAge: Int)
    case postalCode
    case address
    case email
    case birthDate(minAge: Int)
    case birthDateCoInsured(minAge: Int)
    case digits
    case phoneNumber
    case euroBonus
    case firstName
    case lastName
}

@MainActor
public struct Masking {
    public let type: MaskType

    public init(type: MaskType) { self.type = type }

    public func applySettings(_ textField: UITextField) {
        textField.keyboardType = keyboardType
        textField.textContentType = textContentType
        textField.autocapitalizationType = autocapitalizationType
    }

    public func isValid(text: String) -> Bool {
        switch type {
        case .personalNumber:
            let age = calculateAge(from: text)
            return text.replacingOccurrences(of: "-", with: "").count == 12 && age != nil && (age ?? 0) >= 0
        case let .birthDate(minAge):
            let age = calculateAge(from: text) ?? 0
            return minAge...130 ~= age
        case let .birthDateCoInsured(minAge):
            let age = calculateAge(from: text) ?? 0
            return minAge...130 ~= age && text.count == 6
        case .email:
            let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
            return emailPredicate.evaluate(with: text)
        case .postalCode: return unmask(text: text).count == 5
        case .address:
            let addressRegEx = "[(A-Z|Å|Ä|Ö)a-zåäö]+(\\s*)+[0-9]*"
            let addressPredicate = NSPredicate(format: "SELF MATCHES %@", addressRegEx)
            return addressPredicate.evaluate(with: text)
        case .digits: return CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: text))
        case .none: return true
        case .disabledSuggestion: return true
        case .phoneNumber:
            let phoneRegEx = "^[\\+]?[(]?[0-9]{3}[)]?[-\\s\\.]?[0-9]{3}[-\\s\\.]?[0-9]{4,6}$"
            let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegEx)
            return phonePredicate.evaluate(with: text)
        case .euroBonus: return text.count > 3
        case .firstName, .lastName:
            let invalidChars = CharacterSet.whitespaces.union(.letters).union(CharacterSet(charactersIn: "-")).inverted
            let range = text.rangeOfCharacter(from: invalidChars)
            if range != nil {
                return false
            }
            return text.count > 0
        }
    }

    private func unmask(text: String) -> String {
        switch type {
        case .personalNumber: return text.replacingOccurrences(of: "-", with: "")
        case .postalCode: return text.replacingOccurrences(of: "\\s", with: "", options: .regularExpression)
        case .birthDate: return text
        case .email, .digits, .phoneNumber: return text
        case .none: return text
        case .address: return text.replacingOccurrences(of: "\\s", with: "", options: .regularExpression)
        case .disabledSuggestion: return text
        case .euroBonus: return text.replacingOccurrences(of: "-", with: "")
        case .firstName, .lastName: return text
        case .birthDateCoInsured: return text
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

            let components = Calendar.current.dateComponents([.year, .day, .minute], from: dateOfBirth, to: Date())

            guard let age = components.year else { return nil }
            guard let day = components.day else { return nil }
            guard let minutes = components.minute else { return nil }
            if age == 0, day < 0 || minutes < 0 {
                return age - 1
            }
            return age
        }

        let unmaskedValue = self.unmaskedValue(text: text)

        switch type {
        case .personalNumber, .birthDateCoInsured:
            if let age = calculate("yyyyMMdd", value: String(unmaskedValue.prefix(8))) { return age }
            return nil
        case .birthDate:
            guard let age = calculate("yyyy-MM-dd", value: unmaskedValue) else { return nil }
            return age
        default:
            return nil
        }
    }

    public func derivedValues(text: String) -> [String: String]? {
        guard let age = calculateAge(from: text) else { return nil }

        return [".Age": String(age)]
    }

    public var keyboardType: UIKeyboardType {
        switch type {
        case .birthDate, .personalNumber,
            .postalCode, .digits, .birthDateCoInsured:
            return .numberPad
        case .email: return .emailAddress
        case .phoneNumber: return .phonePad
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
        case .phoneNumber: return .telephoneNumber
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
        case .postalCode:
            return nil
        case .email:
            return L10n.emailPlaceholder
        case .phoneNumber:
            return nil
        case .birthDate, .birthDateCoInsured:
            return nil
        case .digits:
            return nil
        case .address:
            return L10n.changeAddressNewAddressLabel
        case .disabledSuggestion:
            return nil
        case .euroBonus:
            return nil
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
        case .personalNumber:
            return nil
        case .postalCode:
            return nil
        case .email:
            return L10n.emailRowTitle
        case .phoneNumber:
            return nil
        case .birthDate, .birthDateCoInsured:
            return nil
        case .digits:
            return nil
        case .address:
            return nil
        case .disabledSuggestion:
            return nil
        case .euroBonus:
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
                let sanitizedText = String(text.filter(\.isDigit))
                return sanitizedText
            }

            return previousText
        }

        switch type {
        case .personalNumber:
            return delimitedDigits(delimiterPositions: [9], maxCount: 13, delimiter: "-")
        case .postalCode: return delimitedDigits(delimiterPositions: [4], maxCount: 6, delimiter: " ")
        case .birthDate, .birthDateCoInsured:
            return delimitedDigits(delimiterPositions: [5, 8], maxCount: 10, delimiter: "-")
        case .digits: return text.filter(\.isDigit)
        case .email: return text
        case .phoneNumber: return text
        case .none: return text
        case .address: return text
        case .disabledSuggestion: return text
        case .euroBonus:
            return uppercasedAlphaNumeric(maxCount: 12)
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
            .introspect(.textField, on: .iOS(.v13...)) { textField in
                textField.spellCheckingType = spellCheckingType
            }
    }
}

extension Character {
    public var isDigit: Bool {
        "0123456789".contains(String(self))
    }
}

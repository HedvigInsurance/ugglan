import Foundation

@MainActor
extension String {
    // converts to a 12 digit personal number
    public var calculate12DigitSSN: String {
        let formattedSSN = replacingOccurrences(of: "-", with: "")
        if formattedSSN.count == 10 {
            let ssnLastTwoDigitsOfYear = formattedSSN.prefix(2)
            let currentYear = Calendar.current.component(.year, from: Date())
            let firstTwoDigitsOfTheYear = currentYear / 100
            let lastTwoDigitsOfTheYear = currentYear % 100

            if let ssnLastTwoDigits = Int(ssnLastTwoDigitsOfYear),
                ssnLastTwoDigits > lastTwoDigitsOfTheYear
            {
                return String(firstTwoDigitsOfTheYear - 1) + self
            } else {
                return String(firstTwoDigitsOfTheYear) + self
            }
        } else {
            return self
        }
    }

    public var calculate10DigitBirthDate: String {
        if let date = localDateToDate ?? localBirthDateStringToDate {
            return date.localDateString
        }
        return ""
    }

    public var birtDateDisplayFormat: String {
        if let date = localDateToDate ?? localBirthDateStringToDate {
            return date.localBirthDateString
        }
        return ""
    }

    public var displayFormatSSN: String? {
        let birthDate = prefix(8)
        let lastFourDigits = String(suffix(4))
        return birthDate + "-" + lastFourDigits
    }
}

import Foundation
import Testing
import UIKit

@testable import hCore

extension HCoreDependencySuite {
    @MainActor
    final class MaskingTests {
        @Test
        func derivedValues() throws {
            let dateMinusOneDay = try #require(Calendar.current.date(byAdding: .day, value: -1, to: Date()))
            let date = try #require(Calendar.current.date(byAdding: .year, value: -7, to: dateMinusOneDay))

            // A local formatter, because Date.localDateString resolves DateService from the DI container
            let birthDateFormatter = DateFormatter()
            birthDateFormatter.dateFormat = "yyyy-MM-dd"

            let birthDateMasking = Masking(type: .birthDate(minAge: 0))
            let birthDateDerivedValues = birthDateMasking.derivedValues(text: birthDateFormatter.string(from: date))
            #expect(birthDateDerivedValues == [".Age": "7"])

            let nonValidBirthDateDerivedValues = birthDateMasking.derivedValues(text: "")
            #expect(nonValidBirthDateDerivedValues == nil)

            let personalNumberMasking = Masking(type: .personalNumber(minAge: 0))

            let personalNumberDateFormatter = DateFormatter()
            personalNumberDateFormatter.dateFormat = "yyyyMMdd"

            let personalNumberDerivedValues = personalNumberMasking.derivedValues(
                text: "\(personalNumberDateFormatter.string(from: date))-8888"
            )
            #expect(personalNumberDerivedValues == [".Age": "7"])

            let nonValidPersonalNumberDerivedValues = personalNumberMasking.derivedValues(text: "")
            #expect(nonValidPersonalNumberDerivedValues == nil)

            let emailMasking = Masking(type: .email)
            let emailDerivedValues = emailMasking.derivedValues(text: "test@hedvig.com")
            #expect(emailDerivedValues == nil)
        }

        @Test
        func shouldRemoveDelimiter() {
            let masking = Masking(type: .birthDate(minAge: 0))
            #expect(masking.maskValue(text: "1993-", previousText: "1993-0") == "1993")
        }

        @Test
        func personalNumber() {
            let masking = Masking(type: .personalNumber(minAge: 0))
            #expect(masking.maskValue(text: "191258475847", previousText: "") == "19125847-5847")
            #expect(masking.maskValue(text: "201258475847", previousText: "") == "20125847-5847")
        }

        @Test
        func birthDate() {
            let masking = Masking(type: .birthDate(minAge: 0))
            #expect(masking.maskValue(text: "19880210", previousText: "") == "1988-02-10")
        }

        @Test
        func digits() {
            let masking = Masking(type: .digits)
            #expect(masking.maskValue(text: "888abc", previousText: "") == "888")
        }

        @Test
        func postalCode() {
            let masking = Masking(type: .postalCode)
            #expect(masking.maskValue(text: "70354", previousText: "") == "703 54")
            #expect(masking.maskValue(text: "703-54", previousText: "") == "703 54")
            #expect(masking.maskValue(text: "703-546", previousText: "703 54") == "703 54")
        }

        @Test
        func email() {
            let masking = Masking(type: .email)
            #expect(masking.maskValue(text: "test@hedvig.com", previousText: "") == "test@hedvig.com")
            #expect(masking.keyboardType == UIKeyboardType.emailAddress)
        }

        @Test
        func keyboardTypes() {
            let maskingPersonalNumber = Masking(type: .personalNumber(minAge: 0))
            #expect(maskingPersonalNumber.keyboardType == UIKeyboardType.numberPad)
            #expect(maskingPersonalNumber.textContentType == nil)

            let maskingEmail = Masking(type: .email)
            #expect(maskingEmail.textContentType == UITextContentType.emailAddress)
            #expect(maskingEmail.keyboardType == UIKeyboardType.emailAddress)
        }
    }
}

import SwiftUI
import hCore
import hCoreUI

public struct DatePickerScreen: View {
    @State private var dateOfOccurrence = Date()
    @PresentableStore var store: ClaimsStore
    let title: String
    var maxDate: String

    public init(
        title: String,
        maxDate: String
    ) {
        self.title = title
        self.maxDate = maxDate
    }

    public var body: some View {
        hForm {
            hSection {
                DatePicker(
                    L10n.Claims.Item.Screen.Date.Of.Incident.button,
                    selection: self.$dateOfOccurrence,
                    in: ...(stringToDate(dateString: maxDate) ?? Date()),
                    displayedComponents: [.date]
                )
                .environment(\.locale, Locale.init(identifier: Localization.Locale.currentLocale.rawValue))
                .datePickerStyle(.graphical)
                .padding([.leading, .trailing], 16)
                .padding([.top], 5)
            }
            .withHeader {
                hText(title, style: .title1)
                    .foregroundColor(hLabelColor.primary)
            }
        }
        .hFormAttachToBottom {

            VStack {

                hButton.LargeButtonFilled {
                    store.send(.submitClaimDateOfOccurrence(dateOfOccurrence: dateOfOccurrence))
                } content: {
                    hText(L10n.generalSaveButton, style: .body)
                        .foregroundColor(hLabelColor.primary.inverted)
                }
                .padding([.leading, .trailing], 16)

                hButton.LargeButtonText {
                    store.send(.dissmissNewClaimFlow)
                } content: {
                    hText(L10n.generalNotSure, style: .body)
                        .foregroundColor(hLabelColor.primary)
                }
                .padding([.leading, .trailing], 16)
            }
        }
    }

    func stringToDate(dateString: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.date(from: dateString) ?? Date()
        return date
    }
}

struct DatePickerView_Previews: PreviewProvider {
    static var previews: some View {
        DatePickerScreen(title: "", maxDate: "")
    }
}

import SwiftUI
import hCore
import hCoreUI

public struct DatePickerScreen: View {
    @State private var dateOfOccurrence = Date()
    @PresentableStore var store: ClaimsStore
    let onSubmit: (Date) -> Void
    let title: String
    var maxDate: Date

    public init(
        title: String,
        maxDate: Date,
        onSubmit: @escaping (Date) -> Void
    ) {
        self.title = title
        self.maxDate = maxDate
        self.onSubmit = onSubmit
    }

    public var body: some View {
        hForm {
            hSection {
                DatePicker(
                    L10n.Claims.Item.Screen.Date.Of.Incident.button,
                    selection: self.$dateOfOccurrence,
                    in: ...maxDate,
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
                    onSubmit(dateOfOccurrence)
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
}

struct DatePickerView_Previews: PreviewProvider {
    static var previews: some View {
        DatePickerScreen(title: "", maxDate: Date()) { _ in

        }
    }
}

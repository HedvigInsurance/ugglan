import SwiftUI
import hCore
import hCoreUI

public struct DatePickerScreen: View {
    @State private var dateOfOccurrence = Date()
    @PresentableStore var store: ClaimsStore

    public init() {}

    public var body: some View {
        hForm {
            hText(L10n.Claims.Incident.Screen.Date.Of.incident, style: .title1)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 16)

            hSection {
                DatePicker(
                    "Termination Date",
                    selection: self.$dateOfOccurrence,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .padding([.leading, .trailing], 16)
                .padding([.top], 5)
            }
        }
        .hFormAttachToBottom {

            VStack {

                hButton.LargeButtonFilled {
                    store.send(.dissmissNewClaimFlow)
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
        DatePickerScreen()
    }
}

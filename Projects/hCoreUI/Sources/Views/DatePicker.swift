import Presentation
import SwiftUI
import hCore

public struct DatePickerView: View {
    @State private var movingDate = Date()
    var onSelect: (Date) -> Void
    //    private let buttonTitle: String?
    //    private let maxDate: Date?
    public init(
        onSelect: @escaping (Date) -> Void
    ) {
        self.onSelect = onSelect
    }

    public var body: some View {
        //        LoadingViewWithContent(.postDateOfOccurrence) {
        hFormNew {
            hSection {
                DatePicker(
                    L10n.Claims.Item.Screen.Date.Of.Incident.button,
                    selection: self.$movingDate,
                    in: ...Date(),
                    displayedComponents: [.date]
                )
                .environment(\.locale, Locale.init(identifier: Localization.Locale.currentLocale.rawValue))
                .datePickerStyle(.graphical)
                .padding([.leading, .trailing], 16)
                .padding([.top], 5)
            }
        }
        .hFormAttachToBottom {
            VStack {
                hButton.LargeButtonFilled {
                    onSelect(movingDate)
                } content: {
                    hText(L10n.Claims.Save.button, style: .body)
                        .foregroundColor(hLabelColor.primary.inverted)
                }
                .padding([.leading, .trailing], 16)

                hButton.LargeButtonText {
                    //action
                } content: {
                    hText(L10n.generalNotSure, style: .body)
                        .foregroundColor(hLabelColor.primary)
                }
                .padding([.leading, .trailing], 16)
            }
        }
        //        }
    }
}

struct DatePickerView_Previews: PreviewProvider {
    static var previews: some View {
        DatePickerView(onSelect: { date in })
    }
}

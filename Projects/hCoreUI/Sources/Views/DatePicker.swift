import Presentation
import SwiftUI
import hCore

public struct DatePickerView: View {
    @State private var movingDate = Date()
    var onSelect: (Date) -> Void

    public init(
        onSelect: @escaping (Date) -> Void
    ) {
        self.onSelect = onSelect
    }

    public var body: some View {
        //        LoadingViewWithContent(.postDateOfOccurrence) {
        hForm {
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
            .sectionContainerStyle(.opaque(useNewDesign: true))
        }
        .hUseNewStyle
        .hFormAttachToBottom {
            VStack {
                hButton.LargeButtonFilled {
                    onSelect(movingDate)
                } content: {
                    hTextNew(L10n.Claims.Save.button, style: .body)
                }
                .padding([.leading, .trailing], 16)

                hButton.LargeButtonText {
                    onSelect(movingDate)
                } content: {
                    hTextNew(L10n.generalNotSure, style: .body)
                        .foregroundColor(hLabelColorNew.primary)
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

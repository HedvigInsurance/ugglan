import SwiftUI
import hCore
import hCoreUI

public struct SetTerminationDate: View {
    @State private var terminationDate = Date()
    @PresentableStore var store: ContractStore

    public init() {}

    public var body: some View {

        hForm {
            HStack(spacing: 0) {
                hText(L10n.setTerminationDateText, style: .body)
                    .padding([.trailing, .leading], 12)
                    .padding([.top, .bottom], 16)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(hBackgroundColor.tertiary)
            .cornerRadius(12)
            .padding(.leading, 16)
            .padding(.trailing, 32)
            .padding(.top, 20)

            hSection {
                hRow {
                    HStack {
                        hText(L10n.terminationDateText, style: .body)
                        Spacer()
                        hText(formatAndPrintDate(), style: .body)
                            .foregroundColor(hLabelColor.link)
                    }
                }

                DatePicker(
                    "Termination Date",
                    selection: self.$terminationDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .padding(.leading, 16)
                .padding([.top], 5)
            }
            .padding(.top, UIScreen.main.bounds.height / 12)
        }
        .hFormAttachToBottom {

            VStack {
                hButton.LargeButtonFilled {
                    store.send(.sendTermination)
                } content: {
                    hText(L10n.generalContinueButton, style: .body)
                        .foregroundColor(hLabelColor.primary.inverted)
                        .frame(minHeight: 52)
                        .frame(minWidth: 200)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding([.top, .leading, .trailing], 16)
            .padding(.bottom, 40)
        }
    }

    func formatAndPrintDate() -> String {
        let dateFormatter = DateFormatter()

        dateFormatter.timeStyle = DateFormatter.Style.none
        dateFormatter.dateStyle = DateFormatter.Style.short
        dateFormatter.dateFormat = "dd-MM-yyyy"
        return dateFormatter.string(from: terminationDate)
    }
}

struct SetTerminationDate_Previews: PreviewProvider {
    static var previews: some View {
        SetTerminationDate()
    }
}

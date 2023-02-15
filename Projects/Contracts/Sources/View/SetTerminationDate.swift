import SwiftUI
import hCore
import hCoreUI

struct SetTerminationDate: View {
    @PresentableStore var store: ContractStore
    @State private var terminationDate = Date()

    var body: some View {

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
                        hText("\(printDate())", style: .body)
                            .foregroundColor(hLabelColor.link)
                    }
                }

                DatePicker(
                    "Termination Date",
                    selection: $terminationDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
            }
            .padding(.top, 60)

            hButton.LargeButtonFilled {
                store.send(.sendTermination)
            } content: {
                hText(L10n.generalContinueButton, style: .body)
                    .foregroundColor(hLabelColor.primary.inverted)
            }
            .padding([.leading, .trailing], 16)
        }
    }

    func printDate() -> String {
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

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
                        hText(printDate(), style: .body)
                            .foregroundColor(hLabelColor.link)
                    }
                }

                DatePicker(
                    "Termination Date",
                    selection: self.$terminationDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .padding([.leading, .trailing], (UIScreen.main.bounds.width) / 30)
                .padding([.top], 5)
            }
            .padding(.bottom, 40)
            //            .padding(.top, (UIScreen.main.bounds.height)/8)
        }
        .padding(.bottom, -200)

        hButton.LargeButtonFilled {
            store.send(.sendTermination)
        } content: {
            hText(L10n.generalContinueButton, style: .body)
                .foregroundColor(hLabelColor.primary.inverted)
        }
        .frame(maxWidth: .infinity, alignment: .bottom)
        .padding([.leading, .trailing], 16)
        .padding(.bottom, 40)
        .padding(.top, 10)
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

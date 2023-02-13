import SwiftUI
import hCore
import hCoreUI

struct SetTerminationDate: View {
    @State private var terminationDate = Date()

    var body: some View {

        hForm {

            //            TODO: Fix
            HStack(alignment: .center, spacing: 0) {
                hText("Please set termination date for your home insurance.", style: .body)
            }
            .padding(.trailing, 16)
            .padding(.top, 20)
            //            .background(Color.blue)
            .cornerRadius(12)

            hSection {
                hRow {
                    HStack {
                        hText("Termination date", style: .body)
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

            .padding(.top, 94)

            hButton.LargeButtonFilled {
                // TODO: Add action
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

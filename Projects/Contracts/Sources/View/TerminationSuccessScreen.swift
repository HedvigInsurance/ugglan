import SwiftUI
import hCore
import hCoreUI

public struct TerminationSuccessScreen: View {
    @State private var terminationDate = Date()
    @PresentableStore var store: ContractStore

    public init() {}

    public var body: some View {

        hForm {
            Image(uiImage: hCoreUIAssets.circularCheckmark.image)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 16)
                .padding(.top, 81)

            hText(L10n.terminationSuccessfulTitle, style: .title1)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 16)
                .padding([.bottom, .top], 10)

            hText(L10n.terminationSuccessfulText(printDate(), "Hedvig"), style: .body)
                .foregroundColor(hLabelColor.secondary)
                .padding([.leading, .trailing], 16)
                .padding(.bottom, 300)
        }
        .padding(.bottom, -100)

        hButton.LargeButtonFilled {
            store.send(.dismissTerminationFlow)
        } content: {
            hText("Done", style: .body)
                .foregroundColor(hLabelColor.primary.inverted)
        }
        .frame(maxWidth: .infinity, alignment: .bottom)
        .padding([.leading, .trailing], 16)
        .padding(.bottom, 40)
    }

    func printDate() -> String {
        let formatter = DateFormatter()
        let myString = formatter.string(from: terminationDate)
        let yourDate = formatter.date(from: myString)
        formatter.dateFormat = "dd-MM-yyyy"
        let myStringDate = formatter.string(from: yourDate!)

        return (myStringDate)
    }

}

struct TerminationSuccessScreen_Previews: PreviewProvider {
    static var previews: some View {
        TerminationSuccessScreen()
    }
}

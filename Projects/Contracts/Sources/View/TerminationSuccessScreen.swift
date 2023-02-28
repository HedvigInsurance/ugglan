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

            hText(L10n.terminationSuccessfulText(formatAndPrintDate(), "Hedvig"), style: .body)
                .foregroundColor(hLabelColor.secondary)
                .padding([.leading, .trailing], 16)
                .padding(.bottom, 300)
        }
        .padding(.bottom, -100)

        hButton.LargeButtonFilled {

            let currentMarket = Localization.Locale.currentLocale.market
            var surveyURL = ""

            switch currentMarket {
            case .se:
                surveyURL =
                    "https://hedvigapp.typeform.com/to/YHVVx1#memberid=xxxxx&contract_id=xxxxx&contract_name=xxxxx&terminated_contracts_count=xxxxx"
            case .no:
                surveyURL = "https://hedvigapp.typeform.com/to/a7aRZzir#memberid=xxxxx"
            case .dk:
                surveyURL = "https://hedvigapp.typeform.com/to/dk9Dj7S8#memberid=xxxxx"
            default:
                break
            }

            if let url = URL(
                string: surveyURL
            ) {
                UIApplication.shared.open(url)
            }
            store.send(.dismissTerminationFlow)
        } content: {
            hText(L10n.continueToSurveyButton, style: .body)
                .foregroundColor(hLabelColor.primary.inverted)
        }
        .frame(maxWidth: .infinity, alignment: .bottom)
        .padding([.leading, .trailing], 16)
        .padding(.bottom, 40)
    }

    func formatAndPrintDate() -> String {
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

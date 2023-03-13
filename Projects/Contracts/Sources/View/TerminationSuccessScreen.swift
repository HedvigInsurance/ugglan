import SwiftUI
import hCore
import hCoreUI

public struct TerminationSuccessScreen: View {
    @PresentableStore var store: ContractStore
    let terminationDate: String
    let surveyURL: String

    public init(
        terminationDate: String,
        surveyURL: String
    ) {
        self.terminationDate = terminationDate
        self.surveyURL = surveyURL
    }

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

            hText(L10n.terminationSuccessfulText(terminationDate, "Hedvig"), style: .body)
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
}

//struct TerminationSuccessScreen_Previews: PreviewProvider {
//    static var previews: some View {
//        TerminationSuccessScreen()
//    }
//}

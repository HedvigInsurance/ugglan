import SwiftUI
import hCore
import hCoreUI

public struct TerminationSuccessScreen: View {
    @PresentableStore var store: ContractStore

    public init() {}

    public var body: some View {

        PresentableStoreLens(
            ContractStore.self,
            getter: { state in
                state.successStep
            }
        ) { termination in

            hForm {
                Image(uiImage: hCoreUIAssets.circularCheckmark.image)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 16)
                    .padding(.top, 81)

                hText(L10n.terminationSuccessfulTitle, style: .title1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 16)
                    .padding([.bottom, .top], 10)

                hText(
                    L10n.terminationSuccessfulText(
                        formatAndPrintDate(dateStringInput: termination?.terminationDate ?? ""),
                        L10n.hedvigNameText
                    ),
                    style: .body
                )
                .foregroundColor(hLabelColor.secondary)
                .padding([.leading, .trailing], 16)
                .padding(.bottom, 300)
            }
            .padding(.bottom, -100)

            hButton.LargeButtonFilled {

                if let surveyToURL = URL(string: termination?.surveyUrl) {
                    UIApplication.shared.open(surveyToURL)
                }
                store.send(.dismissTerminationFlow)

            } content: {
                hText(L10n.terminationOpenSurveyLabel, style: .body)
                    .foregroundColor(hLabelColor.primary.inverted)
            }
            .frame(maxWidth: .infinity, alignment: .bottom)
            .padding([.leading, .trailing], 16)
            .padding(.bottom, 40)
        }
    }

    func formatAndPrintDate(dateStringInput: String) -> String {
        let date = dateStringInput.localDateToDate ?? Date()
        return date.localDateStringDayFirst ?? ""
    }
}

import SwiftUI
import hCore
import hCoreUI

struct TerminationSuccessScreen: View {
    @PresentableStore var store: TerminationContractStore

    init() {}

    var body: some View {

        PresentableStoreLens(
            TerminationContractStore.self,
            getter: { state in
                state.successStep
            }
        ) { termination in
            hForm {
                VStack(spacing: 8) {
                    Image(uiImage: hCoreUIAssets.circularCheckmark.image)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 81)

                    hText(L10n.terminationSuccessfulTitle, style: .title1)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    hText(
                        L10n.terminationSuccessfulText(
                            formatAndPrintDate(dateStringInput: termination?.terminationDate ?? ""),
                            L10n.hedvigNameText
                        ),
                        style: .body
                    )
                    .foregroundColor(hTextColor.secondary)
                    .padding(.bottom, 300)
                }
                .padding(.horizontal, 16)
            }

            hButton.LargeButton(type: .primary) {

                if let surveyToURL = URL(string: termination?.surveyUrl) {
                    UIApplication.shared.open(surveyToURL)
                }
                store.send(.dismissTerminationFlow)

            } content: {
                hText(L10n.terminationOpenSurveyLabel, style: .body)
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

struct CTerminationSuccessScreen_Previews: PreviewProvider {
    static var previews: some View {
        TerminationSuccessScreen()
    }
}

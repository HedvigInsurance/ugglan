import SwiftUI
import hCore
import hCoreUI

struct TerminationSuccessScreen: View {
    @PresentableStore var store: TerminationContractStore

    var body: some View {
        PresentableStoreLens(
            TerminationContractStore.self,
            getter: { state in
                state.successStep
            }
        ) { termination in
            hForm {
                VStack(spacing: 16) {
                    DisplayContractTable(
                        config: .init(
                            contractId: store.state.config?.contractId ?? "",
                            image: nil,
                            contractDisplayName: store.state.config?.contractDisplayName ?? "",
                            contractExposureName: store.state.config?.contractExposureName ?? ""
                        ),
                        terminationDate: (store.state.config?.isDeletion ?? false)
                            ? Date().displayDateDDMMMYYYYFormat ?? ""
                            : termination?.terminationDate?.localDateToDate?.displayDateDDMMMYYYYFormat ?? ""
                    )

                    hSection {
                        InfoCard(
                            text: L10n.terminateContractConfirmationInfoText(
                                (store.state.config?.isDeletion ?? false)
                                    ? Date().displayDateDDMMMYYYYFormat ?? ""
                                    : termination?.terminationDate?.localDateToDate?.displayDateDDMMMYYYYFormat ?? ""
                            ),
                            type: .info
                        )
                    }

                    DisplayQuestionView()
                }
            }
            .padding(.top, 8)
            .hFormAttachToBottom {
                hButton.LargeButton(type: .ghost) {
                    if let surveyToURL = URL(string: termination?.surveyUrl) {
                        store.send(.dismissTerminationFlow)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            store.send(.goToUrl(url: surveyToURL))
                        }
                    }
                } content: {
                    hText(L10n.terminationOpenSurveyLabel)
                }
                .padding(.horizontal, 16)
            }
        }
    }
}

struct CTerminationSuccessScreen_Previews: PreviewProvider {
    static var previews: some View {
        TerminationSuccessScreen()
    }
}

import SwiftUI
import hCoreUI
import hCore

struct CoInsuredMissingAlertView: View {
    let contractId: String
    @PresentableStore var store: ContractStore
    
    var body: some View {
        hForm {
            VStack(spacing: 16) {
                Image(uiImage: hCoreUIAssets.warningTriangleFilled.image)
                    .foregroundColor(hSignalColor.amberElement)
                VStack {
                    let contract = store.state.contractForId(contractId)
                    hText(contract?.currentAgreement?.productVariant.displayName ?? "")
                        .foregroundColor(hTextColor.primaryTranslucent)
                    hText(L10n.contractCoinsuredMissingInformationLabel)
                        .multilineTextAlignment(.center)
                        .foregroundColor(hTextColor.secondaryTranslucent)
                        .padding(.horizontal, 8)
                }
            }
            .padding(.bottom, 32)
        }
        .hFormAttachToBottom {
            VStack(spacing: 8) {
                hButton.LargeButton(type: .primary) {
                    store.send(.openEditCoInsured(contractId: contractId, hasCoInsuredData: false, fromInfoCard: true))
                } content: {
                    hText(L10n.contractCoinsuredMissingAddInfo)
                }
                
                hButton.LargeButton(type: .ghost) {
                    store.send(.coInsuredNavigationAction(action: .dismissEditCoInsuredFlow))
                } content: {
                    hText(L10n.contractCoinsuredMissingLater)
                }
            }
            .padding(16)
        }
    }
}

struct CoInsuredMissingAlertView_Previews: PreviewProvider {
    static var previews: some View {
        CoInsuredMissingAlertView(contractId: "")
    }
}

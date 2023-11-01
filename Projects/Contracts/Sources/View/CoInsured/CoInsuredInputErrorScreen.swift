import SwiftUI
import hCoreUI
import hCore

struct CoInsuredInputErrorScreen: View {
    @PresentableStore var store: ContractStore
    
    var body: some View {
        hForm {
            VStack(spacing: 16) {
                Image(uiImage: hCoreUIAssets.warningTriangleFilled.image)
                    .foregroundColor(hSignalColor.amberElement)
                
                VStack {
                    hText(L10n.somethingWentWrong)
                        .foregroundColor(hTextColor.primaryTranslucent)
                    hText("We can't fetch any information with this personal identity no.")
                        .foregroundColor(hTextColor.secondaryTranslucent)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                }
            }
            .padding(.bottom, 32)
        }
        .hFormAttachToBottom {
            VStack(spacing: 8) {
                hButton.LargeButton(type: .primary) {
                    store.send(.coInsuredNavigationAction(action: .dismissError))
                } content: {
                    hText(L10n.generalRetry)
                }
                hButton.LargeButton(type: .ghost) {
                    store.send(.coInsuredNavigationAction(action: .dismissError))
                } content: {
                    hText(L10n.generalCancelButton)
                }
                
            }
            .padding(16)
        }
    }
}

struct InputErrorScreen_Previews: PreviewProvider {
    static var previews: some View {
        CoInsuredInputErrorScreen()
    }
}

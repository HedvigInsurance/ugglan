import SwiftUI
import hCore
import hCoreUI

struct CoInsuredMissingAlertView: View {
    @PresentableStore var store: EditCoInsuredStore
    let config: InsuredPeopleConfig

    init(
        config: InsuredPeopleConfig
    ) {
        self.config = config
    }

    var body: some View {
        hForm {
            VStack(spacing: 16) {
                Image(uiImage: hCoreUIAssets.warningTriangleFilled.image)
                    .foregroundColor(hSignalColor.amberElement)
                VStack {
                    hText(config.contractDisplayName)
                        .foregroundColor(hTextColor.primaryTranslucent)
                    hText(L10n.contractCoinsuredMissingInformationLabel)
                        .multilineTextAlignment(.center)
                        .foregroundColor(hTextColor.secondaryTranslucent)
                        .padding(.horizontal, 16)
                }
            }
            .padding(.bottom, 32)
        }
        .hFormAttachToBottom {
            VStack(spacing: 8) {
                hButton.LargeButton(type: .primary) {
                    store.send(.coInsuredNavigationAction(action: .dismissEdit))
                    store.send(.openEditCoInsured(config: config, fromInfoCard: true))
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
        CoInsuredMissingAlertView(
            config: InsuredPeopleConfig(
                contractCoInsured: [],
                contractId: "",
                activeFrom: nil,
                numberOfMissingCoInsured: 0,
                displayName: "",
                preSelectedCoInsuredList: [],
                contractDisplayName: "",
                holderFirstName: "",
                holderLastName: "",
                holderSSN: nil
            )
        )
    }
}

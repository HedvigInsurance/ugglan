import Presentation
import SwiftUI
import hCore
import hCoreUI

public struct CoInsuredInfoView: View {
    @PresentableStore var store: EditCoInsuredStore
    @ObservedObject var vm: InsuredPeopleNewScreenModel
    let text: String

    public init(
        text: String,
        config: InsuredPeopleConfig
    ) {
        self.text = text
        let store: EditCoInsuredStore = globalPresentableStoreContainer.get()
        vm = store.coInsuredViewModel
        vm.initializeCoInsured(with: config)
    }

    public var body: some View {
        InfoCard(text: text, type: .attention)
            .buttons([
                .init(
                    buttonTitle: L10n.contractCoinsuredMissingAddInfo,
                    buttonAction: {
                        store.send(
                            .openEditCoInsured(config: vm.config, fromInfoCard: true)
                        )
                    }
                )
            ])
    }
}

public struct CoInsuredInfoHomeView: View {
    @PresentableStore var contractStore: EditCoInsuredStore
    var onTapAction: () -> Void

    public init(
        onTapAction: @escaping () -> Void
    ) {
        self.onTapAction = onTapAction
    }

    public var body: some View {
        InfoCard(text: L10n.contractCoinsuredMissingInfoText, type: .attention)
            .buttons([
                .init(
                    buttonTitle: L10n.contractCoinsuredMissingAddInfo,
                    buttonAction: {
                        onTapAction()
                    }
                )
            ])
    }
}

struct CoInsuredInfoView_Previews: PreviewProvider {
    static var previews: some View {
        CoInsuredInfoView(
            text: "",
            config: InsuredPeopleConfig(
                currentAgreementCoInsured: [],
                upcomingAgreementCoInsured: nil,
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

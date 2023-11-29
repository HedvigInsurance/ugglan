import Presentation
import SwiftUI
import hCore
import hCoreUI

public struct CoInsuredInfoView: View {
    @PresentableStore var store: EditCoInsuredStore
    @ObservedObject var vm: InsuredPeopleNewScreenModel
    let text: String
    let contractId: String

    public init(
        text: String,
        contractId: String
    ) {
        self.text = text
        self.contractId = contractId
        let store: EditCoInsuredStore = globalPresentableStoreContainer.get()
        vm = store.coInsuredViewModel
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
        CoInsuredInfoView(text: "", contractId: "")
    }
}

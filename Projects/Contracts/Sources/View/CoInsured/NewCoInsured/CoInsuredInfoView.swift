import SwiftUI
import hCore
import hCoreUI

struct CoInsuredInfoView: View {
    @PresentableStore var store: ContractStore
    let text: String
    let contractId: String

    init(
        text: String,
        contractId: String
    ) {
        self.text = text
        self.contractId = contractId
    }

    var body: some View {
        InfoCard(text: text, type: .attention)
            .buttons([
                .init(
                    buttonTitle: L10n.contractCoinsuredMissingAddInfo,
                    buttonAction: {
                        if let contract = store.state.contractForId(contractId) {
                            store.send(
                                .openEditCoInsured(config: contract.asEditCoInsuredConfig(), fromInfoCard: true)
                            )
                        }
                    }
                )
            ]
            )
    }
}

public struct CoInsuredInfoHomeView: View {
    @PresentableStore var contractStore: ContractStore
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

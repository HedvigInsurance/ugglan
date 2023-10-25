import SwiftUI
import hCoreUI
import hCore

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
        /* ADD WHEN BACKEND IS DONE */
            InfoCard(text: text, type: .attention)
                .buttons([.init(buttonTitle: "Add information", buttonAction: {
                    store.send(.openEditCoInsured(contractId: contractId, hasCoInsuredData: false))
                    
                })])
    }
}

struct CoInsuredInfoView_Previews: PreviewProvider {
    static var previews: some View {
        CoInsuredInfoView(text: "", contractId: "")
    }
}

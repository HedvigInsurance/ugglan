import SwiftUI
import hCore
import hCoreUI

public struct TerminationFailScreen: View {
    @PresentableStore var store: ContractStore

    public init() {}

    public var body: some View {

        hForm {
            hText(L10n.terminationNotSuccessfulTitle, style: .title1)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .frame(maxWidth: .infinity, alignment: .center)

        hButton.LargeButtonFilled {
            store.send(.dismissTerminationFlow)
        } content: {
            hText(L10n.generalCloseButton, style: .body)
                .foregroundColor(hLabelColor.primary.inverted)
        }
        .frame(maxWidth: .infinity, alignment: .bottom)
        .padding([.leading, .trailing], 16)
        .padding(.bottom, 40)
    }
}

struct TerminationFailScreen_Previews: PreviewProvider {
    static var previews: some View {
        TerminationFailScreen()
    }
}

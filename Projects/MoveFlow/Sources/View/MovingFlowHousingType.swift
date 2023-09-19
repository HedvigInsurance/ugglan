import Presentation
import SwiftUI
import hCore
import hCoreUI

public struct MovingFlowHousingType: View {
    @PresentableStore var store: MoveFlowStore
    let housingTypes = ["Bostadsrätt", "Hyresrätt", "Villa"]
    @State var isSelected: String = ""

    public init() {
        store.send(.getMoveIntent)
    }

    public var body: some View {

        LoadingViewWithContent(MoveFlowStore.self, [.fetchMoveIntent], [.getMoveIntent]) {
            hForm {
                VStack {
                    ForEach(housingTypes, id: \.self) { type in
                        setCheckBoxComponent(text: type)
                    }
                }
            }
            .hFormTitle(.standard, .title3, L10n.changeAddressSelectHousingTypeTitle)
            .hFormAttachToBottom {
                VStack(spacing: 8) {
                    InfoCard(text: L10n.changeAddressCoverageInfoText, type: .info)
                    hButton.LargeButton(type: .primary) {
                        store.send(.navigation(action: .openAddressFillScreen))
                    } content: {
                        hText(L10n.generalContinueButton, style: .body)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                }
            }
        }
    }

    @ViewBuilder
    func setCheckBoxComponent(text: String) -> some View {
        CheckBoxComponent(
            title: text,
            selectedValue: { val in
                isSelected = val
            }
        )
    }
}

struct MovingFlowTypeOfHome_Previews: PreviewProvider {
    static var previews: some View {
        MovingFlowHousingType()
    }
}

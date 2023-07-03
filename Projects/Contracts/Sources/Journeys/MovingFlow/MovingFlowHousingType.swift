import Presentation
import SwiftUI
import hCore
import hCoreUI

public struct MovingFlowHousingType: View {
    @PresentableStore var store: ContractStore
    let housingTypes = ["Bostadsrätt", "Hyresrätt", "Villa"]
    @State var isSelected: String = ""

    public init() {
        store.send(.getMoveIntent)
    }

    public var body: some View {
        LoadingViewWithContent(.setMoveIntent) {
            hForm {
                VStack {
                    ForEach(housingTypes, id: \.self) { type in
                        setCheckBoxComponent(text: type)
                    }

                    InfoCard(text: L10n.changeAddressCoverageInfoText)
                        .padding(.top, 100)
                }
            }
            .hFormTitle(.standard, .title3, L10n.changeAddressSelectHousingTypeTitle)
            .hUseNewStyle
            .hFormAttachToBottom {
                hButton.LargeButtonFilled {
                    store.send(.navigationActionMovingFlow(action: .openAddressFillScreen))
                    // send isSelected to next view
                } content: {
                    hTextNew(L10n.generalContinueButton, style: .body)
                }
                .padding(.horizontal, 16)
            }
        }
    }

    @ViewBuilder
    func setCheckBoxComponent(text: String) -> some View {
        hSection {
            hRow {
                displayContent(displayName: text)
            }
            .withEmptyAccessory
            .onTap {
                isSelected = text
            }
        }
        .padding(.bottom, -4)
    }

    @ViewBuilder
    func displayContent(displayName: String) -> some View {
        Image(uiImage: hCoreUIAssets.pillowHome.image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 48, height: 48)
        hTextNew(displayName, style: .body)
            .foregroundColor(hLabelColorNew.primary)
        Spacer()
        Circle()
            .strokeBorder(
                getBorderColor(currentItem: displayName),
                lineWidth: displayName == isSelected ? 0 : 1.5
            )
            .background(Circle().foregroundColor(retColor(currentItem: displayName)))
            .frame(width: 28, height: 28)
    }

    @hColorBuilder
    func getBorderColor(currentItem: String) -> some hColor {
        if currentItem == isSelected {
            hLabelColorNew.primary
        } else {
            hBackgroundColorNew.semanticBorderTwo
        }
    }

    @hColorBuilder
    func retColor(currentItem: String) -> some hColor {
        if currentItem == isSelected {
            hLabelColorNew.primary

        } else {
            hBackgroundColorNew.opaqueOne
        }
    }
}

struct MovingFlowTypeOfHome_Previews: PreviewProvider {
    static var previews: some View {
        MovingFlowHousingType()
    }
}

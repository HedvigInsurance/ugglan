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
                    hTextNew(L10n.changeAddressSelectHousingTypeTitle, style: .title3)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 54)
                        .padding(.bottom, 64)

                    ForEach(housingTypes, id: \.self) { type in
                        setCheckBoxComponent(text: type)
                    }

                    NoticeComponent(text: L10n.changeAddressCoverageInfoText)
                        .padding(.top, 100)
                }
            }
            .hUseNewStyle
            .hFormAttachToBottom {
                hButton.LargeButtonFilled {
                    store.send(.navigationActionMovingFlow(action: .openAddressFillScreen))
                    // send isSelected to next view
                } content: {
                    hTextNew(L10n.generalContinueButton, style: .body)
                }
                .padding([.leading, .trailing], 16)
            }
        }
    }

    @ViewBuilder
    func setCheckBoxComponent(text: String) -> some View {
        hSection {
            hRow {
                Image(uiImage: hCoreUIAssets.pillowHome.image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 48, height: 48)

                hTextNew(text, style: .body)
                Spacer()
                Circle()
                    .strokeBorder(hGrayscaleColorNew.greyScale900)
                    .background(Circle().foregroundColor(retColor(text: text)))
                    .frame(width: 28, height: 28)
            }
            .withEmptyAccessory
            .onTap {
                isSelected = text
            }
        }
        .withoutVerticalPadding
        .sectionContainerStyle(.opaque(useNewDesign: true))
    }

    @hColorBuilder
    func retColor(text: String) -> some hColor {
        if isSelected == text {
            hGrayscaleColorNew.greyScale900
        } else {
            hGrayscaleColorNew.greyScale100
        }
    }
}

struct MovingFlowTypeOfHome_Previews: PreviewProvider {
    static var previews: some View {
        MovingFlowHousingType()
    }
}

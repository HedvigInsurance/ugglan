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
            hFormNew {
                VStack {
                    hTextNew(L10n.changeAddressSelectHousingTypeTitle, style: .title3)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding([.top, .bottom], 50)

                    ForEach(housingTypes, id: \.self) { type in
                        setCheckBoxComponent(text: type)
                    }

                    NoticeComponent(text: L10n.changeAddressCoverageInfoText)
                        .padding(.top, 116)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding([.leading, .trailing], 16)
                }
            }
            .hFormAttachToBottomNew {
                hButton.LargeButtonFilled {
                    store.send(.navigationActionMovingFlow(action: .openAddressFillScreen))
                    // send isSelected to next view
                } content: {
                    hTextNew(L10n.generalContinueButton, style: .body)
                        .foregroundColor(hLabelColor.primary).colorInvert()
                }
                .padding([.leading, .trailing], 16)
            }
        }
    }

    @ViewBuilder
    func setCheckBoxComponent(text: String) -> some View {
        HStack {
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
        .padding([.top, .bottom], 16)
        .padding([.leading, .trailing], 16)
        .background(
            Squircle.default()
                .fill(hGrayscaleColorNew.greyScale100)
        )
        .padding([.leading, .trailing], 16)
        .onTapGesture {
            isSelected = text
        }
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

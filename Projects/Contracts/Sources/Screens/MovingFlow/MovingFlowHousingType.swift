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
                    hText(L10n.changeAddressSelectHousingTypeTitle, style: .title1)
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
            .hFormAttachToBottom {
                hButton.LargeButtonFilled {
                    store.send(.navigationActionMovingFlow(action: .openAddressFillScreen))
                    // send isSelected to next view
                } content: {
                    hText(L10n.generalContinueButton, style: .body)
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

            hText(text, style: .body)
            Spacer()
            Image(uiImage: (isSelected == text) ? hCoreUIAssets.circleFill.image : hCoreUIAssets.circleEmpty.image)
                .resizable()
                .aspectRatio(contentMode: .fit)
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
}

struct MovingFlowTypeOfHome_Previews: PreviewProvider {
    static var previews: some View {
        MovingFlowHousingType()
    }
}

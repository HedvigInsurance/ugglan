import SwiftUI
import hCore
import hCoreUI

public struct TravelInsuranceFailScreen: View {
    @PresentableStore var store: TravelInsuranceStore

    public init() {}

    public var body: some View {
        hForm {
            Image(uiImage: hCoreUIAssets.warningTriangle.image)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 16)
                .padding([.bottom, .top], 4)

            hText(L10n.terminationNotSuccessfulTitle, style: .title2)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 16)
                .padding(.bottom, 4)

            hText(L10n.somethingWentWrong, style: .body)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 16)
        }
        .frame(maxWidth: .infinity, alignment: .leading)

        .hFormAttachToBottom {
            VStack {
                hButton.LargeButtonOutlined {
                    store.send(.navigation(.dismissCreateTravelCertificate))
                } content: {
                    hText(L10n.generalCloseButton, style: .body)
                        .foregroundColor(hLabelColor.primary)
                }
                .padding(.bottom, 4)
                hButton.LargeButtonPrimary {
                    store.send(.navigation(.openFreeTextChat))
                } content: {
                    hText(L10n.MovingUwFailure.buttonText, style: .body)
                        .foregroundColor(hLabelColor.primary.inverted)
                }
                .padding(.bottom, 2)
            }
            .padding([.leading, .trailing, .bottom], 16)
        }
    }
}

struct TravelInsuranceFailScreen_Previews: PreviewProvider {
    static var previews: some View {
        TravelInsuranceFailScreen()
    }
}

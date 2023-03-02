import SwiftUI
import hCore
import hCoreUI

public struct SubmitClaimOccurrenceScreen: View {
    @PresentableStore var store: ClaimsStore
    public var fromOrigin: ClaimsOrigin

    public init(
        origin: ClaimsOrigin
    ) {
        fromOrigin = origin
    }

    public var body: some View {

        hForm {

            hButton.SmallButtonText {
                store.send(.openDatePicker)
            } content: {

                HStack(spacing: 0) {
                    hText(L10n.Claims.Incident.Screen.Date.Of.incident)
                        .padding([.top, .bottom], 16)

                    Spacer()

                    Image(uiImage: hCoreUIAssets.calendar.image)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(hBackgroundColor.tertiary)
            .cornerRadius(12)
            .padding(.leading, 16)
            .padding(.trailing, 16)
            .padding(.top, 20)

            hButton.SmallButtonText {
                store.send(.openLocation)
            } content: {

                HStack(spacing: 0) {
                    hText(L10n.Claims.Incident.Screen.location)
                        .padding([.top, .bottom], 16)

                    Spacer()

                    hText(L10n.Claim.Location.choose)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(hBackgroundColor.tertiary)
            .cornerRadius(12)
            .padding(.leading, 16)
            .padding(.trailing, 16)
            .padding(.top, 20)

        }

        .hFormAttachToBottom {

            hButton.LargeButtonFilled {

                store.send(.submitClaimAudioRecordingOrInfo)

            } content: {
                hText(L10n.generalContinueButton, style: .body)
                    .foregroundColor(hLabelColor.primary.inverted)
            }
            .frame(maxWidth: .infinity, alignment: .bottom)
            .padding([.leading, .trailing], 16)
        }

    }
}
//
//struct SubmitClaimOccurranceScreen_Previews: PreviewProvider {
//    static var previews: some View {
////        SubmitClaimOccurrenceScreen(origin: ClaimsOrigin())
//    }
//}

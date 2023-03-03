import SwiftUI
import hCore
import hCoreUI

public struct SubmitClaimOccurrenceScreen: View {
    @PresentableStore var store: ClaimsStore

    public init() {}

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
            .frame(height: 64)
            .background(hBackgroundColor.tertiary)
            .cornerRadius(12)
            .padding(.leading, 16)
            .padding(.trailing, 16)
            .padding(.top, 20)

            hButton.SmallButtonText {
                store.send(.openLocationPicker)
            } content: {

                HStack(spacing: 0) {
                    hText(L10n.Claims.Incident.Screen.location)
                        .padding([.top, .bottom], 16)

                    Spacer()

                    hText(L10n.Claim.Location.choose)
                }
            }
            .frame(height: 64)
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

struct SubmitClaimOccurranceScreen_Previews: PreviewProvider {
    static var previews: some View {
        SubmitClaimOccurrenceScreen()
    }
}

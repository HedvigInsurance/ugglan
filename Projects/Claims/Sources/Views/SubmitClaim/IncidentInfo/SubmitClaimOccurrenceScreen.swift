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
                        .foregroundColor(hLabelColor.primary)
                        .padding([.top, .bottom], 16)

                    Spacer()

                    PresentableStoreLens(
                        ClaimsStore.self,
                        getter: { state in
                            state.newClaims
                        }
                    ) { claim in

                        if claim.dateOfOccurrence != nil {
                            hText(claim.dateOfOccurrence ?? "")
                                .foregroundColor(hLabelColor.primary)
                        } else {
                            Image(uiImage: hCoreUIAssets.calendar.image)
                                .foregroundColor(hLabelColor.primary)
                        }
                    }
                }
            }
            .frame(height: 64)
            .background(hBackgroundColor.tertiary)
            .cornerRadius(12)
            .padding(.leading, 16)
            .padding(.trailing, 16)
            .padding(.top, 20)
            .hShadow()

            hButton.SmallButtonText {
                store.send(.openLocationPicker(context: ""))
            } content: {

                HStack(spacing: 0) {
                    hText(L10n.Claims.Incident.Screen.location)
                        .foregroundColor(hLabelColor.primary)
                        .padding([.top, .bottom], 16)

                    Spacer()

                    PresentableStoreLens(
                        ClaimsStore.self,
                        getter: { state in
                            state.newClaims
                        }
                    ) { claim in

                        if claim.location != nil {
                            hText(claim.location?.displayValue ?? "")
                                .foregroundColor(hLabelColor.primary)
                        } else {
                            hText(L10n.Claim.Location.choose)
                                .foregroundColor(hLabelColor.primary)
                        }
                    }
                }
            }
            .frame(height: 64)
            .background(hBackgroundColor.tertiary)
            .cornerRadius(12)
            .padding(.leading, 16)
            .padding(.trailing, 16)
            .padding(.top, 20)
            .hShadow()

        }

        .hFormAttachToBottom {

            hButton.LargeButtonFilled {

                store.send(.submitOccuranceAndLocation)

                store.send(.dissmissNewClaimFlow)
            } content: {
                hText(L10n.generalContinueButton, style: .body)
                    .foregroundColor(hLabelColor.primary.inverted)
            }
            .frame(maxWidth: .infinity, alignment: .bottom)
            .padding([.leading, .trailing], 16)
        }

    }

    func dateToString(date: Date) -> String {

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
}

struct SubmitClaimOccurranceScreen_Previews: PreviewProvider {
    static var previews: some View {
        SubmitClaimOccurrenceScreen()
    }
}

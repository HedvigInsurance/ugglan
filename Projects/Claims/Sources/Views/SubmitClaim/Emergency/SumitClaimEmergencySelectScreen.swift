import SwiftUI
import hCore
import hCoreUI

struct SumitClaimEmergencySelectScreen: View {
    @State var selectedYes: Bool = true
    @PresentableStore var store: SubmitClaimStore
    
    var body: some View {
        hForm {}
            .hFormTitle(.small, .title1, L10n.submitClaimEmergencyTitle)
            .hDisableScroll
            .hFormAttachToBottom {
                VStack(spacing: 16) {
                    buttonView()
                    hButton.LargeButtonPrimary {
                        if selectedYes {
                            store.send(.navigationAction(action: .openEmergencyScreen))
                        } else {
                            /** TODO: SEND MUTATION **/
                        }
                    } content: {
                        hText(L10n.generalContinueButton)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
            }
    }
    
    func buttonView() -> some View {
        HStack(spacing: 8) {
            if selectedYes {
                hButton.MediumButtonPrimaryAlt {
                } content: {
                    hText(L10n.General.yes)
                }
            } else {
                hButton.MediumButtonSecondary {
                    selectedYes = true
                } content: {
                    hText(L10n.General.yes)
                }
            }
            if selectedYes {
                hButton.MediumButtonSecondary {
                    selectedYes = false
                } content: {
                    hText(L10n.General.no)
                }
            } else {
                hButton.MediumButtonPrimaryAlt {
                } content: {
                    hText(L10n.General.no)
                }
            }
        }
    }
}

struct SumitClaimEmergencySelectScreen_Previews: PreviewProvider {
    static var previews: some View {
        SumitClaimEmergencySelectScreen()
    }
}

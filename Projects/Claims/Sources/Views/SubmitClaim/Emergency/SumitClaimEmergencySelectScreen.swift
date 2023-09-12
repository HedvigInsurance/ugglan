import SwiftUI
import hCoreUI
import hCore

struct SumitClaimEmergencySelectScreen: View {
    var body: some View {
        hForm {}
            .hFormTitle(.small, .title1, L10n.submitClaimEmergencyTitle)
            .hDisableScroll
            .hFormAttachToBottom {
                VStack(spacing: 16) {
                    HStack(spacing: 8) {
                        hButton.MediumButtonPrimaryAlt {
                            
                        } content: {
                            hText(L10n.General.yes)
                        }
                        hButton.MediumButtonSecondary {
                            
                        } content: {
                            hText(L10n.General.no)
                        }
                    }
                    hButton.LargeButtonPrimary {
                        
                    } content: {
                        hText(L10n.generalContinueButton)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
            }
    }
}

struct SumitClaimEmergencySelectScreen_Previews: PreviewProvider {
    static var previews: some View {
        SumitClaimEmergencySelectScreen()
    }
}

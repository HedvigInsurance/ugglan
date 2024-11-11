import SwiftUI
import hCore
import hCoreUI

struct SubmitClaimCarScreen: View {
    let model: FlowClaimDeflectStepModel?
    @EnvironmentObject var claimsNavigationVm: ClaimsNavigationViewModel

    init(
        model: FlowClaimDeflectStepModel?
    ) {
        self.model = model
    }

    var body: some View {
        hForm {
            hSection {
                VStack(alignment: .leading, spacing: 8) {
                    hText(L10n.submitClaimCarReportClaimTitle)
                    hText(L10n.submitClaimCarReportClaimText)
                        .foregroundColor(hTextColor.Opaque.secondary)
                }
            }
            .sectionContainerStyle(.transparent)
            .padding(.top, .padding16)
        }
        .hFormAttachToBottom {
            hSection {
                hButton.LargeButton
                    .init(type: .primary) {
                        if let url = URL(string: model?.partners.first?.url) {
                            UIApplication.shared.open(url)
                            let delayTime = 60.0 * 3
                            DispatchQueue.main.asyncAfter(deadline: .now() + delayTime) {
                                claimsNavigationVm.router.dismiss()
                            }
                        }
                    } content: {
                        HStack(spacing: 8) {
                            hText(L10n.submitClaimCarReportClaimButton)
                            Image(uiImage: hCoreUIAssets.arrowNorthEast.image)
                        }
                    }
            }
            .sectionContainerStyle(.transparent)
        }
    }
}

#Preview {
    SubmitClaimCarScreen(model: .init(id: .FlowClaimDeflectEirStep, partners: [], isEmergencyStep: false))
}

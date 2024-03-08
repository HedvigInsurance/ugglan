import SwiftUI
import hCore
import hCoreUI

struct SubmitClaimCarScreen: View {
    let model: FlowClaimDeflectStepModel?
    @PresentableStore var store: SubmitClaimStore

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
                        .foregroundColor(hTextColor.secondary)
                    hButton.LargeButton
                        .init(type: .primary) {
                            if let url = URL(string: model?.partners.first?.url) {
                                store.send(.dissmissNewClaimFlow)
                                UIApplication.shared.open(url)
                            }
                        } content: {
                            HStack(spacing: 8) {
                                hText(L10n.submitClaimCarReportClaimButton)
                                Image(uiImage: hCoreUIAssets.neArrowSmall.image)
                            }
                        }
                        .padding(.top, 65)

                }
            }
            .sectionContainerStyle(.transparent)
            .padding(.top, 16)
        }
    }
}

#Preview{
    SubmitClaimCarScreen(model: .init(id: .FlowClaimDeflectEirStep, partners: [], isEmergencyStep: false))
}

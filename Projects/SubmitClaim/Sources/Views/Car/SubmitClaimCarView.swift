import SwiftUI
import hCore
import hCoreUI

struct SubmitClaimCarView: View {
    let model: FlowClaimDeflectStepModel?
    @EnvironmentObject var claimsNavigationVm: SubmitClaimNavigationViewModel

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
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .sectionContainerStyle(.transparent)
            .padding(.top, .padding16)
        }
        .hFormAttachToBottom {
            hSection {
                hButton(
                    .large,
                    .primary,
                    content: .init(
                        title: L10n.submitClaimCarReportClaimButton,
                        buttonImage: .init(
                            image: hCoreUIAssets.arrowNorthEast.view,
                            alignment: .trailing
                        )
                    ),
                    {
                        if let url = URL(string: model?.partners.first?.url) {
                            Dependencies.urlOpener.open(url)
                            let delayTime = 60.0 * 3
                            DispatchQueue.main.asyncAfter(deadline: .now() + delayTime) {
                                claimsNavigationVm.router.dismiss()
                            }
                        }
                    }
                )
            }
            .sectionContainerStyle(.transparent)
        }
    }
}

#Preview {
    let model = FlowClaimDeflectStepModel(
        id: .FlowClaimDeflectEirStep,
        infoText: nil,
        warningText: nil,
        infoSectionText: nil,
        infoSectionTitle: nil,
        infoViewTitle: nil,
        infoViewText: nil,
        questions: [],
        partners: []
    )
    SubmitClaimCarView(model: model)
}

import SwiftUI
import hCore
import hCoreUI

struct AddonLearnMoreView: View {
    let model: AddonInfo

    var body: some View {
        hForm {
            VStack(spacing: .padding16) {
                hSection {
                    VStack(alignment: .leading, spacing: .padding4) {
                        hText(model.title, style: .body2)
                        hText(model.description, style: .body2)
                            .foregroundColor(hTextColor.Opaque.secondary)
                    }
                }
                .sectionContainerStyle(.transparent)
                VStack(spacing: .padding4) {
                    PerilCollection(perils: model.perils)
                }
            }
        }
    }
}

#Preview {
    AddonLearnMoreView(
        model: .init(
            title: "What is Travel Insurance Plus?",
            description:
                "Travel Insurance Plus is extended coverage for those who want to add to the basic travel coverage included in their Hedvig Home Insurance.",
            perils: [
                .init(id: "id", title: "Peril1", description: "jnbv", color: nil, covered: []),
                .init(id: "id", title: "Peril2", description: "jnbv", color: nil, covered: []),
            ]
        )
    )
}

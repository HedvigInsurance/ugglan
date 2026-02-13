import SwiftUI
import hCore
import hCoreUI

struct AddonLearnMoreView: View {
    let model: AddonInfo
    let multipleGroups: Bool

    init(model: AddonInfo) {
        self.model = model
        multipleGroups = model.perilGroups.count > 1
    }

    var body: some View {
        hForm {
            VStack(alignment: .leading, spacing: .padding8) {
                hSection {
                    headerText
                    pillSection
                }
                .sectionContainerStyle(.transparent)
                VStack(alignment: .leading, spacing: .padding8) {
                    ForEach(model.perilGroups, id: \.title) { perilGroup in
                        if multipleGroups {
                            hSection {
                                HStack {
                                    hText(perilGroup.title)
                                    Spacer()
                                }
                            }
                            .sectionContainerStyle(.transparent)
                        }
                        VStack(spacing: .padding4) {
                            PerilCollection(perils: perilGroup.perils)
                        }
                    }
                }
            }
        }
    }

    private var headerText: some View {
        VStack(alignment: .leading, spacing: .padding4) {
            hText(model.title, style: .body2)
                .accessibilityAddTraits(.isHeader)
            hText(model.description, style: .body1)
                .foregroundColor(hTextColor.Opaque.secondary)
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    private var pillSection: some View {
        hPill(text: L10n.addonLearnMoreLabel, color: .blue)
            .hFieldSize(.medium)
            .padding(.top, .padding32)
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityAddTraits(.isHeader)
    }
}

#Preview {
    AddonLearnMoreView(
        model: .init(
            title: "What is Travel Insurance Plus?",
            description:
                "Travel Insurance Plus is extended coverage for those who want to add to the basic travel coverage included in their Hedvig Home Insurance.",
            perilGroups: [
                .init(
                    title: "group 1",
                    perils: [
                        .init(
                            id: "id",
                            title: "Peril1",
                            description: "description",
                            color: nil,
                            covered: []
                        ),
                        .init(
                            id: "id",
                            title: "Peril2",
                            description: "description",
                            color: nil,
                            covered: []
                        ),
                    ]
                )
            ]
        )
    )
}

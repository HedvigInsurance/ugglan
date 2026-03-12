import SwiftUI
import hCore
import hCoreUI

struct AddonLearnMoreView: View {
    let model: AddonInfo

    init(model: AddonInfo) {
        self.model = model
    }

    var body: some View {
        hForm {
            VStack(alignment: .leading, spacing: .padding8) {
                hSection {
                    headerText
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .sectionContainerStyle(.transparent)
                VStack(alignment: .leading, spacing: .padding8) {
                    ForEach(model.perilGroups, id: \.title) { perilGroup in
                        hSection {
                            pillSection(title: perilGroup.title)
                        }
                        .sectionContainerStyle(.transparent)
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

    private func pillSection(title: String) -> some View {
        hPill(text: title, color: .blue)
            .hFieldSize(.medium)
            .padding(.top, .padding24)
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
                ),
                .init(
                    title: "group 2",
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
                ),
            ]
        )
    )
}

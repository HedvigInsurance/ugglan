import SwiftUI
import hCore

public struct InsurableLimitsSectionView: View {
    var limits: [InsurableLimits]
    var didTap: (_ limit: InsurableLimits) -> Void

    public init(
        limits: [InsurableLimits],
        didTap: @escaping (InsurableLimits) -> Void
    ) {
        self.limits = limits
        self.didTap = didTap
    }

    public var body: some View {
        hSection(limits, id: \.label) { limit in
            hRow {
                hText(limit.label)
            }
            .withCustomAccessory {
                HStack(spacing: 0) {
                    Spacer()
                    HStack(alignment: .top) {
                        Spacer()
                        if let limit = limit.limit {
                            ZStack {
                                hText(limit)
                                    .foregroundColor(hTextColor.Opaque.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .multilineTextAlignment(.trailing)
                                hText(" ")
                            }
                        }
                        hCoreUIAssets.infoFilled.view
                            .resizable()
                            .foregroundColor(hTextColor.Opaque.secondary)
                            .frame(width: 20, height: 20)
                            .padding(.vertical, .padding4)
                            .onTapGesture {
                                didTap(limit)
                            }
                    }
                    .fixedSize(horizontal: false, vertical: true)
                }
            }
            .onTap {
                didTap(limit)
            }
        }
        .sectionContainerStyle(.transparent)
    }
}

#Preview {
    let limits: [InsurableLimits] = [
        .init(label: "TITLE", limit: "LIMIT", description: "DESCRIPTION"),
        .init(label: "VERY LONG TITLE TITLE", limit: "VERY LONG LIMIT LIMIT LIMIT", description: "DESCRIPTION"),
        .init(
            label: "VERY VERY VERY VERY VERY LONG TITLE TITLE",
            limit: "VERY LONG LIMIT LIMIT LIMIT",
            description: "DESCRIPTION"
        ),
    ]

    return VStack {
        InsurableLimitsSectionView(limits: limits) { _ in
        }
        Spacer()
    }
}

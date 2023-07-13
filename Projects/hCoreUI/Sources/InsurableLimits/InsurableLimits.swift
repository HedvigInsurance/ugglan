import Presentation
import SwiftUI
import hCore
import hGraphQL

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
                VStack(alignment: .leading, spacing: 4) {
                    hText(limit.label)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .withCustomAccessory {
                Spacer()
                hText(limit.limit)
                    .foregroundColor(hTextColorNew.secondary)
                Image(uiImage: hCoreUIAssets.infoIconFilled.image)
                    .foregroundColor(hTextColorNew.secondary)
            }
            .onTap {
                didTap(limit)
            }
        }
        .withoutHorizontalPadding
        .sectionContainerStyle(.transparent)
    }
}

import Presentation
import SwiftUI
import hCore
import hGraphQL

public struct InsurableLimitsSectionView<Header: View>: View {
    var header: Header?
    var limits: [InsurableLimits]
    var didTap: (_ limit: InsurableLimits) -> Void

    public init(
        header: Header? = nil,
        limits: [InsurableLimits],
        didTap: @escaping (InsurableLimits) -> Void
    ) {
        self.header = header
        self.limits = limits
        self.didTap = didTap
    }

    public var body: some View {
        hSection(limits, id: \.label) { limit in
            hRow {
                VStack(alignment: .leading, spacing: 4) {
                    hText(limit.label)
                        .fixedSize(horizontal: false, vertical: true)
                    hText(limit.limit)
                        .foregroundColor(hLabelColor.secondary)
                }
            }
            .withCustomAccessory {
                Spacer()
                Image(uiImage: hCoreUIAssets.infoIcon.image)
            }
            .onTap {
                didTap(limit)
            }
        }
        .withHeader {
            header
        }
    }
}

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
                        .frame(maxHeight: .infinity, alignment: .top)
                }
            }
            .withCustomAccessory {
                Spacer()
                HStack(alignment: .center) {
                    hText(limit.limit)
                        .fixedSize(horizontal: false, vertical: true)
                        .foregroundColor(hTextColor.secondary)
                    Image(uiImage: hCoreUIAssets.infoIconFilled.image)
                        .resizable()
                        .foregroundColor(hTextColor.secondary)
                        .frame(width: 16, height: 16)
                        .onTapGesture {
                            didTap(limit)
                        }
                }
                .frame(maxHeight: .infinity, alignment: .top)
            }
            .onTap {
                didTap(limit)
            }
        }
        .withoutHorizontalPadding
        .sectionContainerStyle(.transparent)
    }
}

public struct InsurableLimits: Codable, Hashable {
    public let label: String
    public let limit: String
    public let description: String

    public init(
        label: String,
        limit: String,
        description: String
    ) {
        self.label = label
        self.limit = limit
        self.description = description
    }

    public init(
        fragment: GiraffeGraphQL.InsurableLimitFragment
    ) {
        label = fragment.label
        limit = fragment.limit
        description = fragment.description
    }

    init(
        _ data: OctopusGraphQL.ProductVariantFragment.InsurableLimit
    ) {
        label = data.label
        limit = data.limit
        description = data.description
    }
}

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
                hText(limit.label)
            }
            .withCustomAccessory {
                HStack(spacing: 0) {
                    Spacer()
                    HStack(alignment: .top) {
                        hText(limit.limit)
                            .fixedSize()
                            .foregroundColor(hTextColor.secondary)
                        Image(uiImage: hCoreUIAssets.infoIconFilled.image)
                            .resizable()
                            .foregroundColor(hTextColor.secondary)
                            .frame(width: 16, height: 16)
                            .padding(.vertical, 4)
                            .onTapGesture {
                                didTap(limit)
                            }

                    }
                    .frame(maxHeight: .infinity, alignment: .top)
                    .fixedSize()
                }
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
        _ data: OctopusGraphQL.ProductVariantFragment.InsurableLimit
    ) {
        label = data.label
        limit = data.limit
        description = data.description
    }
}

struct InsurableLimitsSectionView_Previews: PreviewProvider {
    static var previews: some View {
        let limits: [InsurableLimits] = [
            .init(label: "TITLE", limit: "LIMIT", description: "DESCRIPTION"),
            .init(label: "VERY LONG TITLE TITLE", limit: "VERY LONG LIMIT LIMIT LIMIT", description: "DESCRIPTION"),
        ]

        return VStack {
            InsurableLimitsSectionView(limits: limits) { _ in

            }
            Spacer()
        }
    }
}

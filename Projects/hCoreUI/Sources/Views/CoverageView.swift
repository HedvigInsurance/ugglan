import SwiftUI
import hCore

public struct CoverageView: View {
    let limits: [InsurableLimits]
    var didTapInsurableLimit: (_ limit: InsurableLimits) -> Void
    let perils: [(title: String?, perils: [Perils])]

    public init(
        limits: [InsurableLimits],
        didTapInsurableLimit: @escaping (_ limit: InsurableLimits) -> Void,
        perils: [(title: String?, perils: [Perils])]
    ) {
        self.limits = limits
        self.didTapInsurableLimit = didTapInsurableLimit
        self.perils = perils
    }

    public var body: some View {
        VStack(spacing: .padding16) {
            InsurableLimitsSectionView(
                limits: limits
            ) { limit in
                didTapInsurableLimit(limit)
            }
            .hWithoutHorizontalPadding([.row, .divider])
            VStack(spacing: .padding32) {
                ForEach(perils, id: \.title) { perils in
                    VStack(spacing: .padding8) {
                        if let title = perils.title {
                            hSection {
                                HStack {
                                    hPill(text: title, color: .blue)
                                        .hFieldSize(.medium)
                                    Spacer()
                                }
                            }
                        }
                        VStack(spacing: .padding4) {
                            PerilCollection(
                                perils: perils.perils
                            )
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    CoverageView(
        limits: [],
        didTapInsurableLimit: { limit in

        },
        perils: [
            (
                nil,
                perils: [
                    .init(id: "id1", title: "title1", description: "description1", color: nil, covered: [])
                ]
            ),
            (
                "title1",
                perils: [
                    .init(id: "id2", title: "title12", description: "description2", color: nil, covered: [])
                ]
            ),
        ]
    )
}

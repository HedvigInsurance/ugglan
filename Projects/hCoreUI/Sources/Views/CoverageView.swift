import SwiftUI
import hCore
import hGraphQL

public struct CoverageView: View {
    let limits: [InsurableLimits]
    var didTapInsurableLimit: (_ limit: InsurableLimits) -> Void
    let perils: [Perils]

    public init(
        limits: [InsurableLimits],
        didTapInsurableLimit: @escaping (_ limit: InsurableLimits) -> Void,
        perils: [Perils]
    ) {
        self.limits = limits
        self.didTapInsurableLimit = didTapInsurableLimit
        self.perils = perils
    }

    public var body: some View {
        VStack(spacing: 4) {
            InsurableLimitsSectionView(
                limits: limits
            ) { limit in
                didTapInsurableLimit(limit)
            }
            PerilCollection(
                perils: perils
            )
            .hFieldSize(.small)
        }
    }
}

import Foundation
import Presentation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

public struct CrossSellingCoverageDetail: View {
    @PresentableStore var store: ContractStore
    var crossSell: CrossSell

    public init(
        crossSell: CrossSell
    ) {
        self.crossSell = crossSell
    }

    public var body: some View {
        hForm {
            if let perils = crossSell.info?.perils {
                hSection(header: hText("Coverage")) {
                    PerilCollection(perils: perils) { peril in
                        store.send(.openCrossSellingCoverageDetailPeril(peril: peril))
                    }
                }
                .sectionContainerStyle(.transparent)
            }

            if let insurableLimits = crossSell.info?.insurableLimits {
                InsurableLimitsSectionView(
                    header: hText(
                        L10n.contractCoverageMoreInfo,
                        style: .headline
                    )
                    .foregroundColor(hLabelColor.secondary),
                    limits: insurableLimits
                ) { limit in
                    store.send(.openCrossSellingCoverageDetailInsurableLimit(insurableLimit: limit))
                }
            }

        }
        .hFormAttachToBottom {
            ContinueButton(crossSell: crossSell)
        }
    }
}

extension CrossSellingCoverageDetail {
    public func journey(
        style: PresentationStyle = .default,
        options: PresentationOptions = [.defaults]
    ) -> some JourneyPresentation {
        HostingJourney(
            ContractStore.self,
            rootView: self,
            style: style,
            options: options
        ) { action in
            if case let .openCrossSellingCoverageDetailPeril(peril) = action {
                Journey(
                    PerilDetail(peril: peril),
                    style: .detented(.preferredContentSize, .large)
                )
            } else if case let .openCrossSellingCoverageDetailInsurableLimit(limit) = action {
                InsurableLimitDetail(limit: limit).journey
            }
        }
        .withDismissButton
    }
}

import Flow
import Foundation
import Presentation
import SafariServices
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

public struct CrossSellingCoverageDetail: View {
    @PresentableStore var store: ContractStore
    var crossSell: CrossSell
    var crossSellInfo: CrossSellInfo

    public init(
        crossSell: CrossSell,
        crossSellInfo: CrossSellInfo
    ) {
        self.crossSell = crossSell
        self.crossSellInfo = crossSellInfo
    }

    public var body: some View {
        hForm {
            if !crossSellInfo.perils.isEmpty {
                hSection(header: hText(L10n.CrossSell.Info.coverageTitle)) {
                    PerilCollection(perils: crossSellInfo.perils) { peril in
                        store.send(.crossSellingCoverageDetailNavigation(action: .peril(peril: peril)))
                    }
                }
                .sectionContainerStyle(.transparent)
            }

            if !crossSellInfo.insurableLimits.isEmpty {
                InsurableLimitsSectionView(
                    limits: crossSellInfo.insurableLimits
                ) { limit in
                    store.send(.crossSellingCoverageDetailNavigation(action: .insurableLimit(insurableLimit: limit)))
                }
            }

            if !crossSellInfo.insuranceTerms.isEmpty {
                InsuranceTermsSection(terms: crossSellInfo.insuranceTerms) { insuranceTerm in
                    store.send(
                        .crossSellingCoverageDetailNavigation(action: .insuranceTerm(insuranceTerm: insuranceTerm))
                    )
                }
            }

        }
        .hFormAttachToBottom {
            ContinueButton(crossSell: crossSell)
        }
    }
}

extension CrossSellingCoverageDetail {
    public func journey<Next: JourneyPresentation>(
        @JourneyBuilder _ next: @escaping (_ result: CrossSellingDetailResult) -> Next,
        style: PresentationStyle = .default,
        options: PresentationOptions = [.defaults]
    ) -> some JourneyPresentation {
        HostingJourney(
            ContractStore.self,
            rootView: self,
            style: style,
            options: options
        ) { action in
            if case let .crossSellingCoverageDetailNavigation(action: .peril(peril)) = action {
                Journey(
                    PerilDetail(peril: peril),
                    style: .detented(.preferredContentSize, .large)
                )
                .withDismissButton
            } else if case let .crossSellingCoverageDetailNavigation(action: .insurableLimit(limit)) = action {
                InsurableLimitDetail(limit: limit).journey
            } else if case let .crossSellingCoverageDetailNavigation(action: .insuranceTerm(insuranceTerm)) = action {
                Journey(
                    Document(url: insuranceTerm.url, title: insuranceTerm.displayName),
                    style: .detented(.large)
                )
                .setScrollEdgeNavigationBarAppearanceToStandard
                .withDismissButton
            } else if case let .crossSellingDetailEmbark(name) = action {
                next(.embark(name: name))
            }
        }
        .configureTitle(L10n.CrossSell.Info.fullCoverageRow)
    }
}

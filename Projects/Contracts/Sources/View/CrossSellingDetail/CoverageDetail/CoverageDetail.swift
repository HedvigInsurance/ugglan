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

    public init(
        crossSell: CrossSell
    ) {
        self.crossSell = crossSell
    }

    public var body: some View {
        hForm {
            if let perils = crossSell.info?.perils {
                hSection(header: hText(L10n.CrossSell.Info.coverageTitle)) {
                    PerilCollection(perils: perils) { peril in
                        store.send(.crossSellingCoverageDetailNavigation(action: .peril(peril: peril)))
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
                    store.send(.crossSellingCoverageDetailNavigation(action: .insurableLimit(insurableLimit: limit)))
                }
            }

            if let insuranceTerms = crossSell.info?.insuranceTerms {
                InsuranceTermsSection(terms: insuranceTerms) { insuranceTerm in
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
            if case let .crossSellingCoverageDetailNavigation(action: .peril(peril)) = action {
                Journey(
                    PerilDetail(peril: peril),
                    style: .detented(.preferredContentSize, .large)
                )
                .withDismissButton
            } else if case let .crossSellingCoverageDetailNavigation(action: .insurableLimit(limit)) = action {
                InsurableLimitDetail(limit: limit).journey.withDismissButton
            } else if case let .crossSellingCoverageDetailNavigation(action: .insuranceTerm(insuranceTerm)) = action {
                Journey(
                    Document(url: insuranceTerm.url, title: insuranceTerm.displayName),
                    style: .detented(.large)
                )
                .setScrollEdgeNavigationBarAppearanceToStandard
                .withDismissButton
            }
        }
        .withJourneyDismissButton
    }
}

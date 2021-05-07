import Apollo
import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI
import hGraphQL

struct FutureSection { @Inject var client: ApolloClient }

extension FutureSection: Viewable {
	func materialize(events _: ViewableEvents) -> (SectionView, Disposable) {
		let bag = DisposeBag()
		let section = SectionView()
		section.dynamicStyle = .brandGrouped(separatorType: .none)

		var titleLabel = MultilineLabel(value: "", style: .brand(.largeTitle(color: .primary)))
		bag += section.append(titleLabel)

		section.appendSpacing(.inbetween)

		var subtitleLabel = MultilineLabel(value: "", style: .brand(.body(color: .secondary)))
		bag += section.append(subtitleLabel)

		bag += combineLatest(
			client.fetch(query: GraphQL.HomeQuery()).valueSignal,
			client.fetch(
				query: GraphQL.HomeInsuranceProvidersQuery(
					locale: Localization.Locale.currentLocale.asGraphQLLocale()
				)
			).valueSignal
		).onValue { homeData, insuranceProvidersData in
			if let contract = homeData.contracts.first(where: {
				$0.status.asActiveInFutureStatus != nil || $0.status.asPendingStatus != nil
			}) {
				if let activeInFutureStatus = contract.status.asActiveInFutureStatus {
					titleLabel.value = L10n.HomeTab.activeInFutureWelcomeTitle(
						homeData.member.firstName ?? "",
						activeInFutureStatus.futureInception ?? ""
					)
					subtitleLabel.value = L10n.HomeTab.activeInFutureBody
				} else if let switchedFromInsuranceProvider = contract.switchedFromInsuranceProvider,
					let insuranceProvider = insuranceProvidersData.insuranceProviders.first(where: {
						provider -> Bool in provider.id == switchedFromInsuranceProvider
					}), insuranceProvider.switchable
				{
					titleLabel.value = L10n.HomeTab.pendingSwitchableWelcomeTitle(
						homeData.member.firstName ?? ""
					)
					subtitleLabel.value = L10n.HomeTab.pendingNonswitchableBody
				} else {
					titleLabel.value = L10n.HomeTab.pendingNonswitchableWelcomeTitle(
						homeData.member.firstName ?? ""
					)
					subtitleLabel.value = L10n.HomeTab.pendingNonswitchableBody
				}
			}
		}

		return (section, bag)
	}
}

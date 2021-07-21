import Apollo
import Flow
import Foundation
import Offer
import Presentation
import hCore
import hGraphQL

public struct UgglanState: Codable, EmptyInitable {
	var selectedTabIndex = 0

	public enum Feature: Codable {
		case referrals
		case keyGear
	}

	var features: [Feature]? = nil
    
    public init() {}
}

public enum UgglanAction: Codable {
	case setSelectedTabIndex(index: Int)
	case fetchFeatures
	case setFeatures(features: [UgglanState.Feature]?)
}

public final class UgglanStore: StateStore<UgglanState, UgglanAction> {
	@Inject var client: ApolloClient

	public override func effects(_ getState: () -> UgglanState, _ action: UgglanAction) -> Future<UgglanAction>? {
		switch action {
		case .fetchFeatures:
			return
				client.fetch(
					query: GraphQL.FeaturesQuery(),
					cachePolicy: .fetchIgnoringCacheData
				)
				.compactMap { $0.member.features }
                .map { features in
                    .setFeatures(
                        features: [
                            features.contains(.referrals) ? .referrals : nil,
                            features.contains(.keyGear) ? .keyGear : nil
                        ].compactMap { $0 }
                    )
                }
		default:
			break
		}

		return nil
	}

	public override func reduce(_ state: UgglanState, _ action: UgglanAction) -> UgglanState {
		var newState = state

		switch action {
		case let .setSelectedTabIndex(tabIndex):
			newState.selectedTabIndex = tabIndex
		case let .setFeatures(features):
			newState.features = features
		default:
			break
		}

		return newState
	}
}

import Apollo
import Flow
import Foundation
import Offer
import Presentation
import hCore
import hGraphQL

public struct UgglanState: StateProtocol {
    var selectedTabIndex: Int = 0

	public enum Feature: Codable {
		case referrals
		case keyGear
	}

    var features: [Feature]?

	public init() {}
}

public enum UgglanAction: ActionProtocol {
	case setSelectedTabIndex(index: Int)
	case makeForeverTabActive
	case fetchFeatures
	case setFeatures(features: [UgglanState.Feature]?)

	#if compiler(<5.5)
		public func encode(to encoder: Encoder) throws {
			#warning("Waiting for automatic codable conformance from Swift 5.5, remove this when we have upgraded XCode")
			fatalError()
		}

		public init(
			from decoder: Decoder
		) throws {
			#warning("Waiting for automatic codable conformance from Swift 5.5, remove this when we have upgraded XCode")
			fatalError()
		}
	#endif
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
							features.contains(.keyGear) ? .keyGear : nil,
						]
						.compactMap { $0 }
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

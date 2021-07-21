import Apollo
import Flow
import Foundation
import Presentation
import hCore
import hGraphQL

public struct OfferState: Codable, EmptyInitable {
	var hasSignedQuotes = false
	var chatOpened = false
	var ids: [String] = []

	public init() {}
}

public enum OfferAction: Codable {
	case hasSignedQuotes(value: Bool)
	case openChat
	case closeChat
	case query
}

public final class OfferStore: StateStore<OfferState, OfferAction> {
	@Inject var client: ApolloClient
	@Inject var store: ApolloStore

	func query(for state: State) -> GraphQL.QuoteBundleQuery {
		GraphQL.QuoteBundleQuery(
			ids: state.ids,
			locale: Localization.Locale.currentLocale.asGraphQLLocale()
		)
	}

	override public func effects(_ getState: () -> State, _ action: Action) -> Future<Action>? {
		return nil
	}

	override public func reduce(_ state: OfferState, _ action: OfferAction) -> OfferState {
		var newState = state

		switch action {
		case let .hasSignedQuotes(hasSignedQuotes):
			newState.hasSignedQuotes = hasSignedQuotes
		case .openChat:
			newState.chatOpened = true
		case .closeChat:
			newState.chatOpened = false
		default:
			break
		}

		return newState
	}
}

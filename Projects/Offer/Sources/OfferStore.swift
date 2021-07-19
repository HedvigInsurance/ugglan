import Apollo
import Flow
import Foundation
import Presentation
import hCore
import hGraphQL

public struct OfferState: Codable {
	var hasSignedQuotes = false
	var chatOpened = false
	var ids: [String] = []
}

public enum OfferAction {
	case hasSignedQuotes(_ value: Bool)
	case openChat
	case closeChat
	case query
	case queryResponse(_ data: GraphQL.QuoteBundleQuery.Data)
}

public final class OfferStore: Store {
	@Inject var client: ApolloClient
	@Inject var store: ApolloStore

	public var providedSignal: ReadWriteSignal<OfferState>
	public var onAction = Callbacker<OfferAction>()

	func query(for state: State) -> GraphQL.QuoteBundleQuery {
		GraphQL.QuoteBundleQuery(
			ids: state.ids,
			locale: Localization.Locale.currentLocale.asGraphQLLocale()
		)
	}

	public func effects(_ state: OfferState, _ action: OfferAction) -> Future<OfferAction>? {
		switch action {
		case .query:
			return client.fetch(query: query(for: state)).map { .queryResponse($0) }
		default:
			break
		}

		return nil
	}

	public func reduce(_ state: OfferState, _ action: OfferAction) -> OfferState {
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

	public init() {
		self.providedSignal = ReadWriteSignal(
			Self.restore() ?? OfferState()
		)
	}
}

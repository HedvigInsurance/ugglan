import Apollo
import Flow
import Form
import Foundation
import UIKit
import hCore
import hCoreUI

struct ApolloMultilineLabel<Query: GraphQLQuery> {
	let query: Query
	@Inject private var client: ApolloClient
	let mapDataAndStyle: (_ data: Query.Data) -> StyledText

	init(query: Query, mapDataAndStyle: @escaping (_ data: Query.Data) -> StyledText) {
		self.query = query
		self.mapDataAndStyle = mapDataAndStyle
	}
}

extension ApolloMultilineLabel: Viewable {
	func materialize(events _: ViewableEvents) -> (MultilineLabel, Disposable) {
		let bag = DisposeBag()
		let multilineLabel = MultilineLabel(value: "", style: TextStyle.brand(.body(color: .primary)))

		bag += client.watch(query: query).map { self.mapDataAndStyle($0) }.map { $0.text }.bindTo(
			multilineLabel.$value
		)

		bag += client.watch(query: query).map { self.mapDataAndStyle($0) }.map { $0.style }.bindTo(
			multilineLabel.$style
		)

		return (multilineLabel, bag)
	}
}

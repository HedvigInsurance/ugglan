import Apollo
import Embark
import Flow
import Form
import Foundation
import Presentation
import TestingUtil
import UIKit
import hCore
import hCoreUI
import hGraphQL

public struct Debug {
	public init() {}

	enum Component: String, CaseIterable {
		case multiAction = "Multi Action"
		case numberAction = "Number Action"

		var json: JSONObject { EmbarkStory.makeFor(component: self).jsonObject }
	}
}

extension EmbarkStory {
	fileprivate static func makeFor(component: Debug.Component) -> GraphQL.EmbarkStoryQuery.Data {
		var action: GraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage.Action?

		switch component {
		case .multiAction: action = mockedMultiAction
		case .numberAction: action = embarkNumberAction
		}

		func passage(name: String) -> GraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage {
			GraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage(
				id: name,
				name: "Enter Address",
				externalRedirect: nil,
				offerRedirect: nil,
				tooltips: [],
				allLinks: [],
				response: .makeEmbarkMessage(text: "Mocked Repsonse", expressions: []),
				messages: [.init(text: "Enter buildings", expressions: [])],
				api: nil,
				redirects: [],
				tracks: [],
				action: action
			)
		}

		let mockedStory = GraphQL.EmbarkStoryQuery.Data.EmbarkStory(
			id: "asd",
			startPassage: "asd123",
			name: "Mocked Story",
			passages: [passage(name: "asd123"), passage(name: "asd1234")]
		)

		let mockedData = GraphQL.EmbarkStoryQuery.Data(embarkStory: mockedStory)

		return mockedData
	}

	fileprivate static let mockedMultiAction = GraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage.Action
		.makeEmbarkMultiAction(
			multiActionData: .init(
				addLabel: "Add Building",
				key: "multiActionItem",
				maxAmount: "5",
				link: .init(name: "asd1234", label: "Next"),
				components: [
					EmbarkStory.embarkNumberComponent, EmbarkStory.embarkDropDownComponent,
					EmbarkStory.embarkSwitchComponent,
				]
			),
			component: ""
		)

	fileprivate static let embarkNumberComponent = GraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage.Action
		.AsEmbarkMultiAction.MultiActionDatum.Component.makeEmbarkMultiActionNumberAction(
			data: .init(
				key: "Embark Test Nubmeraction",
				placeholder: "478",
				unit: "m",
				label: "Size of building"
			)
		)

	fileprivate static let embarkDropDownComponent = GraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage.Action
		.AsEmbarkMultiAction.MultiActionDatum.Component.makeEmbarkDropdownAction(
			dropDownActionData: .init(
				label: "Building Type",
				key: "type",
				options: [
					.init(value: "garage", text: "garage"),
					.init(value: "boat house", text: "boat house"),
				]
			)
		)

	fileprivate static let embarkSwitchComponent = GraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage.Action
		.AsEmbarkMultiAction.MultiActionDatum.Component.makeEmbarkSwitchAction(
			switchActionData: .init(label: "Is there water", key: "water", defaultValue: true)
		)

	fileprivate static let embarkNumberAction = GraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage.Action
		.makeEmbarkNumberAction(
			component: "",
			numberActionData: .init(
				key: "year",
				placeholder: "year",
				link: .init(name: "continue", label: "continue")
			)
		)
}

extension Debug: Presentable {
	public func materialize() -> (UIViewController, Disposable) {
		let viewController = UIViewController()
		viewController.title = "Embark Test"

		let bag = DisposeBag()

		let tableKit = TableKit<EmptySection, StringRow>(holdIn: bag)
		bag += viewController.install(tableKit)

		func present(component: Component) {
			let apolloClient = ApolloClient(
				networkTransport: MockNetworkTransport(body: component.json),
				store: ApolloStore()
			)

			Dependencies.shared.add(module: Module { () -> ApolloClient in apolloClient })

			bag +=
				viewController.present(
					Embark(name: "Mocked Story", menu: Menu(title: nil, children: [])),
					options: [.autoPop]
				)
				.nil()
		}

		let components = Component.allCases

		let rows = components.map { StringRow(value: $0.rawValue) }

		tableKit.set(Table(rows: rows))

		bag += tableKit.delegate.didSelectRow.onValue { row in
			present(component: Component(rawValue: row.value)!)
		}

		return (viewController, bag)
	}
}

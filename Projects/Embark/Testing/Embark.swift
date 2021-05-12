import Apollo
import Embark
import Flow
import Form
import Foundation
import hCore
import hGraphQL
import Offer
import Presentation
import TestingUtil
import UIKit

public struct Debug {
    public init() {}

    enum Component: CaseIterable {
        case multiAction
        case numberAction

        var json: JSONObject {
            EmbarkStory.makeFor(component: self).jsonObject
        }

        var title: String {
            switch self {
            case .multiAction:
                return "Multi Action"
            case .numberAction:
                return "Number Action"
            }
        }
    }
}

private extension EmbarkStory {
    static func makeFor(component: Debug.Component) -> GraphQL.EmbarkStoryQuery.Data {
        var action: GraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage.Action?

        switch component {
        case .multiAction:
            action = mockedMultiAction
        case .numberAction:
            action = embarkNumberAction
        }

        let passage = GraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage(
            id: "asd123",
            name: "Enter Address",
            externalRedirect: nil,
            offerRedirect: nil,
            tooltips: [],
            allLinks: [],
            response: .makeEmbarkMessage(
                text: "Mocked Repsonse",
                expressions: []
            ),
            messages: [],
            api: nil,
            redirects: [],
            tracks: [],
            action: action
        )

        let mockedStory = GraphQL.EmbarkStoryQuery.Data.EmbarkStory(
            id: "asd",
            startPassage: "asd123",
            name: "Mocked Story",
            passages: [passage]
        )

        let mockedData = GraphQL.EmbarkStoryQuery.Data(embarkStory: mockedStory)

        return mockedData
    }

    static let mockedMultiAction = GraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage.Action.makeEmbarkMultiAction(
        multiActionData: .init(
            addLabel: "Add Building",
            maxAmount: "1",
            link: .init(name: "Next", label: "Next"),
            components: [EmbarkStory.embarkNumberComponent]
        ),
        component: ""
    )

    static let embarkNumberComponent = GraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage.Action.AsEmbarkMultiAction.MultiActionDatum.Component.makeEmbarkNumberAction(
        numberActionData: .init(key: "Embark Test Nubmeraction",
                                placeholder: "478",
                                link: .init(
                                    name: "next passage",
                                    label: "Continue"
                                ))
    )

    static let embarkNumberAction = GraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage.Action.makeEmbarkNumberAction(
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

        let form = FormView()

        let section = form.appendSection(
            headerView: UILabel(
                value: "Components",
                style: .default
            ),
            footerView: nil
        )

        func present(component: Component) {
            let apolloClient = ApolloClient(
                networkTransport: MockNetworkTransport(
                    body: component.json),
                store: ApolloStore()
            )

            Dependencies.shared.add(module: Module { () -> ApolloClient in
                apolloClient
            })

            bag += viewController.present(
                Embark(
                    name: "Mocked Story",
                    menu: Menu(title: nil, children: [])
                ),
                options: [.autoPop]
            )
        }

        let components = Component.allCases

        components.forEach { component in
            bag += section.appendRow(title: component.title).onValue { _ in
                present(component: component)
            }
        }

        bag += viewController.install(form)

        return (viewController, bag)
    }
}

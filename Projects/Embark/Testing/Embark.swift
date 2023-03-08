import Apollo
import Embark
import Flow
import Form
import Foundation
import Presentation
import TestingUtil
import UIKit
import hCore
import hGraphQL

public struct Debug {
    public init() {}

    enum Component: CaseIterable {
        case multiAction
        case numberAction
        case datePickerAction
        case audioRecorderAction

        var json: JSONObject {
            EmbarkStory.makeFor(component: self).jsonObject
        }

        var title: String {
            switch self {
            case .multiAction:
                return "Multi Action"
            case .numberAction:
                return "Number Action"
            case .datePickerAction:
                return "Date Picker Action"
            case .audioRecorderAction:
                return "Audio Recorder Action"
            }
        }
    }
}

extension EmbarkStory {
    fileprivate static func makeFor(component: Debug.Component) -> GiraffeGraphQL.EmbarkStoryQuery.Data {
        var action: GiraffeGraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage.Action?

        switch component {
        case .multiAction:
            action = mockedMultiAction
        case .numberAction:
            action = embarkNumberAction
        case .datePickerAction:
            action = datePickerAction
        case .audioRecorderAction:
            action = embarkAudioRecorderAction
        }

        let passage = GiraffeGraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage(
            id: "asd123",
            name: "Enter Address",
            externalRedirect: nil,
            quoteCartOfferRedirects: [],
            offerRedirect: nil,
            variantedOfferRedirects: [],
            tooltips: [],
            allLinks: [],
            response: .makeEmbarkMessage(
                text: "Mocked Repsonse",
                expressions: []
            ),
            messages: [.init(text: "Hello there", expressions: [])],
            api: nil,
            redirects: [],
            tracks: [],
            action: action
        )

        let mockedStory = GiraffeGraphQL.EmbarkStoryQuery.Data.EmbarkStory(
            id: "asd",
            startPassage: "asd123",
            name: "Mocked Story",
            passages: [passage]
        )

        let mockedData = GiraffeGraphQL.EmbarkStoryQuery.Data(embarkStory: mockedStory)

        return mockedData
    }

    fileprivate static let datePickerAction = GiraffeGraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage.Action
        .makeEmbarkDatePickerAction(
            component: "",
            next: .init(name: "", hidden: false, label: ""),
            storeKey: "",
            label: "Access Date"
        )

    fileprivate static let mockedMultiAction = GiraffeGraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage.Action
        .makeEmbarkMultiAction(
            multiActionData: .init(
                addLabel: "Add Building",
                maxAmount: "1",
                link: .init(name: "asd1234", hidden: false, label: "Next"),
                components: [
                    EmbarkStory.embarkNumberComponent, EmbarkStory.embarkDropDownComponent,
                    EmbarkStory.embarkSwitchComponent,
                ]
            ),
            component: ""
        )

    fileprivate static let embarkNumberComponent = GiraffeGraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage.Action
        .AsEmbarkMultiAction.MultiActionDatum.Component.makeEmbarkMultiActionNumberAction(
            numberActionData: .init(
                placeholder: "478",
                key: "Embark Test Nubmeraction",
                unit: "m"
            )
        )

    fileprivate static let embarkDropDownComponent = GiraffeGraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage.Action
        .AsEmbarkMultiAction.MultiActionDatum.Component.makeEmbarkDropdownAction(
            dropDownActionData: .init(
                label: "Building Type",
                key: "type",
                options: [
                    .init(
                        value: "garage",
                        text: "garage"
                    ),
                    .init(
                        value: "boat house",
                        text: "boat house"
                    ),
                ]
            )
        )

    fileprivate static let embarkSwitchComponent = GiraffeGraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage.Action
        .AsEmbarkMultiAction.MultiActionDatum.Component.makeEmbarkSwitchAction(
            switchActionData:
                .init(
                    label: "Is there water",
                    key: "water",
                    defaultValue: true
                )
        )

    fileprivate static let embarkNumberAction = GiraffeGraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage.Action
        .makeEmbarkNumberAction(
            component: "",
            numberActionData: .init(
                key: "year",
                placeholder: "year",
                link: .init(name: "continue", hidden: false, label: "continue")
            )
        )

    fileprivate static let embarkAudioRecorderAction = GiraffeGraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage.Action
        .makeEmbarkAudioRecorderAction(
            component: "audioRec",
            audioRecorderData: .init(
                storeKey: "key",
                label: "Continue",
                next: .init(name: "mock", hidden: false, label: "mock")
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
                    body: component.json
                ),
                store: ApolloStore()
            )

            Dependencies.shared.add(
                module: Module { () -> ApolloClient in
                    apolloClient
                }
            )

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
            bag += section.appendRow(title: component.title)
                .onValue { _ in
                    present(component: component)
                }
        }

        bag += viewController.install(form)

        return (viewController, bag)
    }
}

import Contracts
import Foundation
import Presentation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct Debug: View {
    @PresentableStore var store: DebugStore

    var body: some View {
        hForm {
            hSection {
                hRow {
                    hText("Open CrossSellingSigned")
                }
                .onTap {
                    store.send(.openCrossSellingSigned)
                }

                hRow {
                    hText("Open CrossSellingDetail")
                }
                .onTap {
                    store.send(.openCrossSellingDetail)
                }
            }
        }
    }
}

extension Debug {
    static var journey: some JourneyPresentation {
        HostingJourney(
            rootView: Debug()
        )
        .configureTitle("Contracts debug")
        .onAction(DebugStore.self) { action in
            switch action {
            case .openCrossSellingSigned:
                HostingJourney(
                    rootView: CrossSellingSigned(
                        startDate: Date()
                    )
                    .mockState(ContractStore.self) { state in
                        var newState = state

                        newState.focusedCrossSell = .init(
                            title: "Accident insurance",
                            description: "",
                            imageURL: .mock,
                            blurHash: "",
                            buttonText: "",
                            typeOfContract: "SE_ACCIDENT",
                            infos: []
                        )

                        return newState
                    },
                    style: .detented(.large)
                )

            case .openCrossSellingDetail:
                CrossSellingCoverageDetail(crossSell: .mock(), crossSellInfo: .mock())
                    .journey(
                        { _ in
                            ContinueJourney()
                        },
                        style: .detented(.large, modally: true),
                        options: [.embedInNavigationController]
                    )
                    .withDismissButton
                    .scrollEdgeNavigationItemHandler
            }
        }
    }
}

extension CrossSell {
    public static func mock() -> CrossSell {
        .init(
            title: "Title",
            description: "description",
            imageURL: .mock,
            blurHash: "blurHash",
            buttonText: "Button text",
            typeOfContract: "Type of contract",
            infos: []
        )
    }
}

extension CrossSellInfo {
    public static func mock() -> CrossSellInfo {
        .init(
            headerImageURL: URL(string: "")!,
            title: "Title",
            about: "About",
            highlights: [],
            faqs: [],
            insurableLimits: [],
            insuranceTerms: [],
            perils: []
        )
    }
}

import Contracts
import Foundation
import Presentation
import SwiftUI
import hCore
import hCoreUI

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
            if action == .openCrossSellingSigned {
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
                            buttonText: ""
                        )

                        return newState
                    },
                    style: .detented(.large)
                )
            }
        }
    }
}

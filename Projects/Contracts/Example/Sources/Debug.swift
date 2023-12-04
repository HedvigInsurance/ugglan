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
    }
}

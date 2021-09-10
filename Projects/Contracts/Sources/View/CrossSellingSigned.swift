import Foundation
import Presentation
import SwiftUI
import hCore
import hCoreUI

public struct CrossSellingSigned: View {
    @PresentableStore var store: ContractStore
    var startDate: Date?
    
    var displayDate: String {
        guard let startDate = startDate else {
            return ""
        }

        return startDate.localDateString ?? ""
    }

    public var body: some View {
        hForm {
            hSection {
                VStack(alignment: .leading, spacing: 18) {
                    Image(uiImage: hCoreUIAssets.circularCheckmark.image)
                        .resizable()
                        .frame(width: 30, height: 30)
                    hText(store.state.focusedCrossSell?.crossSell.title ?? "", style: .title1)
                        .frame(maxWidth: .infinity)
                    hText(displayDate, style: .body)
                        .foregroundColor(hLabelColor.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .hFormAttachToBottom {
            hSection {
                hButton.LargeButtonFilled {
                    store.send(.setFocusedCrossSell(focusedCrossSell: nil))
                    store.send(.closeCrossSellingSigned)
                } content: {
                    hText(L10n.toolbarDoneButton)
                }
            }
        }
        .sectionContainerStyle(.transparent)
    }
}

struct CrossSellingSignedPreviews: PreviewProvider {
    static var previews: some View {
        JourneyPreviewer(
            CrossSellingSigned.journey(
                startDate: Date()
            )
        )
    }
}

extension CrossSellingSigned {
    public static func journey(startDate: Date?) -> some JourneyPresentation {
        HostingJourney(
            ContractStore.self,
            rootView: CrossSellingSigned(startDate: startDate)
        ) { action in
            if action == .closeCrossSellingSigned {
                DismissJourney()
            }
        }
    }
}

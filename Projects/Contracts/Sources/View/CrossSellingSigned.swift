//
//  CrossSellingSigned.swift
//  CrossSellingSigned
//
//  Created by Sam Pettersson on 2021-09-10.
//  Copyright © 2021 Hedvig AB. All rights reserved.
//

import Foundation
import hCore
import hCoreUI
import SwiftUI
import Presentation

public struct CrossSellingSigned: View {
    @PresentableStore var store: ContractStore
    var startDate: Date?
    
    public var body: some View {
        hForm {
            hSection {
                VStack(alignment: .leading, spacing: 18) {
                    Image(uiImage: hCoreUIAssets.circularCheckmark.image)
                        .resizable()
                        .frame(width: 30, height: 30)
                    hText(store.state.focusedCrossSell?.crossSell.title ?? "", style: .title1)
                        .frame(maxWidth: .infinity)
                    hText(startDate?.localDateStringWithToday ?? "", style: .body)
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

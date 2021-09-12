//
//  Debug.swift
//  Debug
//
//  Created by Sam Pettersson on 2021-09-10.
//  Copyright © 2021 Hedvig AB. All rights reserved.
//

import Foundation
import hCore
import hCoreUI
import SwiftUI
import Presentation
import Contracts

struct Debug: View {
    @PresentableStore var store: DebugStore
    
    var body: some View {
        hForm {
            hSection {
                hRow {
                    hText("Open CrossSellingSigned")
                }.onTap {
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
                    ).mockState(ContractStore.self) { state in
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

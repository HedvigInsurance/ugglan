//
//  CrossSellingInfo.swift
//  CrossSellingInfo
//
//  Created by Sam Pettersson on 2021-10-06.
//  Copyright © 2021 Hedvig AB. All rights reserved.
//

import Foundation
import SwiftUI
import hCoreUI
import hCore
import hGraphQL
import Presentation

public struct CrossSellingDetail: View {
    var crossSell: CrossSell
    
    public init(crossSell: CrossSell) {
        self.crossSell = crossSell
    }
    
    public var body: some View {
        hForm {
            VStack {
                LinearGradient(
                    gradient: Gradient(
                        colors: [.black.opacity(0.5), .clear]
                    ),
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
            .frame(height: 250)
            .backgroundImageWithBlurHashFallback(imageURL: crossSell.imageURL, blurHash: crossSell.blurHash)
            .clipped()
            
            hSection {
                VStack(alignment: .leading) {
                    hText(crossSell.title, style: .title1)
                }
            }.sectionContainerStyle(.transparent)
            
            if let info = crossSell.info {
                CrossSellHightlights(info: info)
            }
        }.edgesIgnoringSafeArea(.top)
    }
}

public enum CrossSellingDetailResult {
    case embark(name: String)
    case chat
}

extension CrossSellingDetail {
    public func journey<Next: JourneyPresentation>(
        @JourneyBuilder _ next: @escaping (_ result: CrossSellingDetailResult) -> Next,
        style: PresentationStyle = .detented(.large),
        options: PresentationOptions = [.defaults]
    ) -> some JourneyPresentation {
        HostingJourney(
            ContractStore.self,
            rootView: self,
            style: style,
            options: options
        ) { action in
            if case let .openCrossSellingEmbark(name) = action {
                next(.embark(name: name))
            } else if case .openCrossSellingChat = action {
                next(.chat)
            }
        }.withDismissButton
    }
}

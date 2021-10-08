//
//  InsurableLimitDetail.swift
//  InsurableLimitDetail
//
//  Created by Sam Pettersson on 2021-10-08.
//  Copyright © 2021 Hedvig AB. All rights reserved.
//

import Foundation
import SwiftUI
import hGraphQL
import Presentation
import hCore

public struct InsurableLimitDetail: View {
    var limit: InsurableLimits
    
    public init(limit: InsurableLimits) {
        self.limit = limit
    }
    
    public var body: some View {
        hForm {
            hSection {
                hText(
                    limit.description,
                    style: .body
                )
                .foregroundColor(hLabelColor.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            }.sectionContainerStyle(.transparent)
        }
    }
}

extension InsurableLimitDetail {
    public var journey: some JourneyPresentation {
        HostingJourney(
            rootView: self,
            style: .detented(.scrollViewContentSize),
            options: [
                .defaults,
                .prefersLargeTitles(true),
                .largeTitleDisplayMode(.always)
            ]
        )
        .configureTitle(L10n.contractCoverageMoreInfo)
        .withDismissButton
    }
}

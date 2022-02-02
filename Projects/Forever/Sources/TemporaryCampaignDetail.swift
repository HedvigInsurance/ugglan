//
//  CampaignDetail.swift
//  Forever
//
//  Created by Sam Pettersson on 2022-01-28.
//  Copyright © 2022 Hedvig AB. All rights reserved.
//

import Foundation
import SwiftUI
import hCore
import hCoreUI
import Presentation

struct TemporaryCampaignDetail: View {
    var body: some View {
        hForm {
            hSection {
                hRow {
                    hText(L10n.referralCampaignDetailBody)
                }
            }
        }
    }
}

extension TemporaryCampaignDetail {
    var journey: some JourneyPresentation {
        HostingJourney(rootView: self)
            .configureTitle(L10n.referralCampaignDetailTitle)
            .setStyle(.detented(.scrollViewContentSize))
            .withDismissButton
    }
}

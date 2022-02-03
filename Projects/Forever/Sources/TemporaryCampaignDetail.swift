import Foundation
import Presentation
import SwiftUI
import hCore
import hCoreUI

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

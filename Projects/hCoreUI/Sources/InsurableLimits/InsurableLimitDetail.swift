import Foundation
import Presentation
import SwiftUI
import hCore
import hGraphQL

public struct InsurableLimitDetail: View {
    var limit: InsurableLimits

    public init(
        limit: InsurableLimits
    ) {
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
            }
            .sectionContainerStyle(.transparent)
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
                .largeTitleDisplayMode(.always),
            ]
        )
        .configureTitle(L10n.contractCoverageMoreInfo)
        .withDismissButton
    }
}

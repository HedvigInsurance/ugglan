import Flow
import Presentation
import SwiftUI
import UIKit
import hCore
import hCoreUI
import hGraphQL

public typealias Tooltip = GraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage.Tooltip

struct EmbarkTooltips { let tooltips: [Tooltip] }

extension EmbarkTooltips: View {
    var body: some View {
        hForm {
            hSection(tooltips, id: \.title) { tooltip in
                VStack(spacing: 12) {
                    hText(tooltip.title, style: .title2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    hText(tooltip.description, style: .body)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(hLabelColor.primary)
                }.padding(.bottom, 15)
            }
        }
        .sectionContainerStyle(.transparent)
    }
}

extension EmbarkTooltips {
    var journey: some JourneyPresentation {
        HostingJourney(
            rootView: self,
            style: .detented(.scrollViewContentSize),
            options: [.defaults]
        )
        .withDismissButton.configureTitle(L10n.OnboardingEmbarkFlow.informationModalTitle)
    }
}

import Foundation
import Presentation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

public struct FAQDetail: View {
    var faq: FAQ

    public init(
        faq: FAQ
    ) {
        self.faq = faq
    }

    public var body: some View {
        hForm {
            hSection {
                VStack(alignment: .leading, spacing: 18) {
                    hText(
                        faq.title,
                        style: .title1
                    )
                    hText(
                        faq.description,
                        style: .body
                    )
                    .foregroundColor(hLabelColor.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .sectionContainerStyle(.transparent)
        }
    }
}

extension FAQDetail {
    public var journey: some JourneyPresentation {
        HostingJourney(
            rootView: self,
            style: .detented(.scrollViewContentSize),
            options: [
                .defaults
            ]
        )
        .withDismissButton
    }
}

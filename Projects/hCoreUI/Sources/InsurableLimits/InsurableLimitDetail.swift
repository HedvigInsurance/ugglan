import Foundation
import Presentation
import SwiftUI
import hCore
import hGraphQL

public struct InsurableLimitDetail: View {
    var limit: InsurableLimits
    var onDismiss: () -> Void

    public init(
        limit: InsurableLimits,
        onDismiss: @escaping () -> Void
    ) {
        self.limit = limit
        self.onDismiss = onDismiss
    }

    public var body: some View {
        hForm {
            hSection {
                VStack(alignment: .leading, spacing: 8) {
                    hText(L10n.contractCoverageMoreInfo)
                    hText(limit.description)
                        .foregroundColor(hTextColorNew.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 8)
                .padding(.top, 32)
            }
            .sectionContainerStyle(.transparent)
        }
        .hFormAttachToBottom {
            hButton.LargeButtonGhost {
                onDismiss()
            } content: {
                hText(L10n.generalCloseButton)
            }
            .padding(.horizontal, 24)
        }
    }
}

extension InsurableLimitDetail {
    public var journey: some JourneyPresentation {
        HostingJourney(
            rootView: self,
            style: .detented(.scrollViewContentSize),
            options: [.blurredBackground]
        )
    }
}

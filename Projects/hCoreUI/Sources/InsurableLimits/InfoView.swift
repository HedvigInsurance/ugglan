import Foundation
import Presentation
import SwiftUI
import hCore
import hGraphQL

public struct InfoView: View {
    let title: String
    let description: String?
    let onDismiss: () -> Void

    public init(
        title: String = L10n.contractCoverageMoreInfo,
        description: String?,
        onDismiss: @escaping () -> Void
    ) {
        self.title = title
        self.description = description
        self.onDismiss = onDismiss
    }

    public var body: some View {
        hForm {
            hSection {
                VStack(alignment: .leading, spacing: 8) {
                    hText(title)
                    hText(description ?? "")
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

extension InfoView {
    public var journey: some JourneyPresentation {
        HostingJourney(
            rootView: self,
            style: .detented(.scrollViewContentSize),
            options: [.blurredBackground]
        )
    }
}

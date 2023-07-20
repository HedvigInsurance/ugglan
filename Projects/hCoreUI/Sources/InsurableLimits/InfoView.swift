import Foundation
import Presentation
import SwiftUI
import hCore
import hGraphQL

public struct InfoView: View {
    let title: String
    let description: String
    let onDismiss: () -> Void
    let extraButton: (text: String, style: hButtonConfigurationType, action: () -> Void)?

    public init(
        title: String,
        description: String,
        onDismiss: @escaping () -> Void,
        extraButton: (text: String, style: hButtonConfigurationType, action: () -> Void)? = nil
    ) {
        self.title = title
        self.description = description
        self.onDismiss = onDismiss
        self.extraButton = extraButton
    }

    public var body: some View {
        hForm {
            hSection {
                VStack(alignment: .leading, spacing: 8) {
                    hText(title)
                    hText(description)
                        .foregroundColor(hTextColorNew.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 8)
                .padding(.top, 32)
            }
            .sectionContainerStyle(.transparent)
            .padding(.bottom, 23)
        }
        .hFormAttachToBottom {
            VStack(spacing: 8) {
                if let button = extraButton {
                    if button.style != .alert {
                        hButton.LargeButtonPrimary {
                            button.action()
                        } content: {
                            hText(button.text)
                        }
                    } else {
                        hButton.LargeButtonPrimaryAlert {
                            button.action()
                        } content: {
                            hText(button.text)
                        }

                    }
                }
                hButton.LargeButtonGhost {
                    onDismiss()
                } content: {
                    hText(L10n.generalCloseButton)
                }
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

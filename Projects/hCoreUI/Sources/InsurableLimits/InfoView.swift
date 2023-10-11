import Flow
import Foundation
import Presentation
import SwiftUI
import hCore
import hGraphQL

public struct InfoViewHolder: View {
    let title: String
    let description: String
    @State private var disposeBag = DisposeBag()
    public init(title: String, description: String) {
        self.title = title
        self.description = description
    }

    public var body: some View {
        SwiftUI.Button {
            showInfoView()
        } label: {
            Image(uiImage: hCoreUIAssets.infoIcon.image)
        }
    }

    private func showInfoView() {
        let cancelAction = ReferenceAction {}
        let view = InfoView(title: title, description: description) {
            cancelAction.execute()
        }
        let journey = HostingJourney(
            rootView: view,
            style: .detented(.scrollViewContentSize),
            options: [.blurredBackground]
        )

        let calendarJourney = journey.addConfiguration { presenter in
            cancelAction.execute = {
                presenter.dismisser(JourneyError.cancelled)
            }
        }
        let vc = UIApplication.shared.getTopViewController()
        if let vc {
            disposeBag += vc.present(calendarJourney)
        }
    }
}

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
                        .foregroundColor(hTextColor.secondary)
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
                        hButton.LargeButton(type: .primary) {
                            button.action()
                        } content: {
                            hText(button.text)
                        }
                    } else {
                        hButton.LargeButton(type: .alert) {
                            button.action()
                        } content: {
                            hText(button.text)
                        }

                    }
                }
                hButton.LargeButton(type: .ghost) {
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

import SwiftUI
import hCore

public struct ConfirmChangesScreen: View {
    let title: String
    let subTitle: String
    let buttons: ConfirmChangesButtonConfig

    public init(
        title: String,
        subTitle: String,
        buttons: ConfirmChangesButtonConfig
    ) {
        self.title = title
        self.subTitle = subTitle
        self.buttons = buttons
    }

    public var body: some View {
        hForm {}
            .hFormContentPosition(.compact)
            .hFormAttachToBottom {
                hSection {
                    VStack(alignment: .center, spacing: 0) {
                        hText(title)
                        hText(subTitle)
                            .foregroundColor(hTextColor.Translucent.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, .padding32)
                    }
                    VStack(spacing: .padding8) {
                        hButton(
                            .large,
                            .primary,
                            content: .init(title: buttons.mainButton.buttonTitle ?? L10n.generalConfirm),
                            {
                                buttons.mainButton.buttonAction()
                            }
                        )

                        hButton(
                            .large,
                            .ghost,
                            content: .init(
                                title: buttons.dismissButton.buttonTitle ?? L10n.generalCloseButton
                            ),
                            {
                                buttons.dismissButton.buttonAction()
                            }
                        )
                    }
                    .padding(.top, .padding24)
                }
                .sectionContainerStyle(.transparent)
            }
    }
}

public struct ConfirmChangesButtonConfig {
    let mainButton: ConfirmChangeButton
    let dismissButton: ConfirmChangeButton

    public init(
        mainButton: ConfirmChangeButton,
        dismissButton: ConfirmChangeButton
    ) {
        self.mainButton = mainButton

        if dismissButton.buttonTitle == nil {
            self.dismissButton = .init(buttonAction: dismissButton.buttonAction)
        } else {
            self.dismissButton = dismissButton
        }
    }

    public struct ConfirmChangeButton {
        let buttonTitle: String?
        let buttonAction: () -> Void

        public init(buttonTitle: String? = nil, buttonAction: @escaping () -> Void) {
            self.buttonTitle = buttonTitle
            self.buttonAction = buttonAction
        }
    }
}

extension ConfirmChangesScreen: TrackingViewNameProtocol {
    public var nameForTracking: String {
        String(describing: self)
    }
}

#Preview {
    ConfirmChangesScreen(
        title: "title",
        subTitle: "sub title",
        buttons: .init(mainButton: .init(buttonAction: {}), dismissButton: .init(buttonAction: {}))
    )
}

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
                    VStack(alignment: .leading, spacing: .padding32) {
                        VStack(alignment: .leading, spacing: 0) {
                            hText(title)
                            hText(subTitle)
                                .foregroundColor(hTextColor.Translucent.secondary)
                        }
                        .padding(.leading, .padding8)
                        VStack(spacing: .padding8) {
                            hButton.LargeButton(type: .primary) {
                                buttons.mainButton.buttonAction()
                            } content: {
                                hText(buttons.mainButton.buttonTitle ?? L10n.generalConfirm)
                            }

                            hButton.LargeButton(type: .ghost) {
                                buttons.dismissButton.buttonAction()
                            } content: {
                                hText(buttons.dismissButton.buttonTitle ?? L10n.generalCloseButton)
                            }
                        }
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

#Preview {
    ConfirmChangesScreen(
        title: "title",
        subTitle: "sub title",
        buttons: .init(mainButton: .init(buttonAction: {}), dismissButton: .init(buttonAction: {}))
    )
}

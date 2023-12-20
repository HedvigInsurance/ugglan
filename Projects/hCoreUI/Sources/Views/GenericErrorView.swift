import SwiftUI
import hCore

public struct GenericErrorView: View {
    private let title: String?
    private let description: String?
    private let icon: ErrorIconType
    private let buttons: ErrorViewButtonConfig

    public init(
        title: String? = nil,
        description: String? = nil,
        icon: ErrorIconType = .triangle,
        buttons: ErrorViewButtonConfig
    ) {
        self.title = title
        self.description = description
        self.icon = icon
        self.buttons = buttons
    }

    public var body: some View {
        hForm {
            VStack(spacing: 16) {
                switch icon {
                case .triangle:
                    Image(uiImage: hCoreUIAssets.warningTriangleFilled.image)
                        .foregroundColor(hSignalColor.amberElement)
                case .circle:
                    Image(uiImage: hCoreUIAssets.infoIconFilled.image)
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(hSignalColor.blueElement)
                }
                VStack {
                    hText(title ?? L10n.somethingWentWrong, style: .body)
                        .foregroundColor(hTextColor.primaryTranslucent)

                    hText(description ?? L10n.General.errorBody, style: .body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(hTextColor.secondaryTranslucent)
                }
                if let actionButton = buttons.actionButton {
                    hButton.MediumButton(type: .primary) {
                        actionButton.buttonAction()
                    } content: {
                        hText(actionButton.buttonTitle ?? L10n.generalRetry, style: .body)
                    }
                    .fixedSize()
                }
            }
            .padding(.horizontal, 32)
        }
        .hFormContentPosition(.center)
        .hFormAttachToBottom {
            hButton.LargeButton(type: .ghost) {
                buttons.dismissButton.buttonAction()
            } content: {
                hText(buttons.dismissButton.buttonTitle ?? L10n.openChat, style: .body)
            }
            .padding([.horizontal, .bottom], 16)
        }
    }
}

public enum ErrorIconType {
    case triangle
    case circle
}

public struct ErrorViewButtonConfig {
    fileprivate let actionButton: ErrorViewButton?
    fileprivate let dismissButton: ErrorViewButton

    public init(
        actionButton: ErrorViewButton? = nil,
        dismissButton: ErrorViewButton
    ) {
        self.actionButton = actionButton
        self.dismissButton = dismissButton
    }

    public struct ErrorViewButton {
        fileprivate let buttonTitle: String?
        fileprivate let buttonAction: () -> Void

        public init(buttonTitle: String? = nil, buttonAction: @escaping () -> Void) {
            self.buttonTitle = buttonTitle
            self.buttonAction = buttonAction
        }
    }
}

#Preview{
    GenericErrorView(
        icon: .circle,
        buttons:
            .init(
                actionButton:
                    .init(
                        buttonAction: {}),
                dismissButton:
                    .init(
                        buttonTitle: "Close",
                        buttonAction: {}
                    )
            )
    )
}

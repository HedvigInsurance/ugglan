import SwiftUI
import hCore

struct StateView: View {
    let type: StateType
    let title: String
    let bodyText: String?
    let button: StateButton?

    var body: some View {
        centralContent
    }

    private var centralContent: some View {
        hSection {
            VStack(spacing: 16) {
                if let image = type.image {
                    Image(uiImage: image)
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(type.imageColor)
                }

                VStack(spacing: 0) {
                    hText(title)
                        .foregroundColor(hTextColor.Opaque.primary)
                    if let bodyText {
                        hText(bodyText)
                            .foregroundColor(hTextColor.Translucent.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, .padding32)
                    }
                }

                if let button {
                    hButton.MediumButton(type: .primary) {
                        button.buttonAction()
                    } content: {
                        hText(button.buttonTitle ?? type.buttonText)
                    }
                    .fixedSize()

                }
            }
        }
        .sectionContainerStyle(.transparent)
    }
}

enum StateType {
    case error
    case information
    case success
    case bankId
    case empty

    var image: UIImage? {
        switch self {
        case .error:
            return hCoreUIAssets.warningTriangleFilled.image
        case .information:
            return hCoreUIAssets.infoFilled.image
        case .success:
            return hCoreUIAssets.checkmarkFilled.image
        case .bankId:
            return hCoreUIAssets.bankID.image
        case .empty:
            return nil
        }
    }

    @hColorBuilder
    var imageColor: some hColor {
        switch self {
        case .error:
            hSignalColor.Amber.element
        case .information:
            hSignalColor.Blue.element
        case .success:
            hSignalColor.Green.element
        default:
            hSignalColor.Amber.element
        }
    }

    var buttonText: String {
        switch self {
        case .error:
            return L10n.generalRetry
        case .information:
            return L10n.generalConfirm
        default:
            return L10n.generalContinueButton
        }
    }
}

public struct StateButton {
    fileprivate let buttonTitle: String?
    fileprivate let buttonAction: () -> Void

    public init(
        buttonTitle: String? = nil,
        buttonAction: @escaping () -> Void
    ) {
        self.buttonTitle = buttonTitle
        self.buttonAction = buttonAction
    }
}

#Preview{
    StateView(
        type: .error,
        title: "title",
        bodyText: "body",
        button: .init(buttonAction: {})
    )
}

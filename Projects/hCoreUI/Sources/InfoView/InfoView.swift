import Foundation
import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect
import hCore
import hGraphQL

public class InfoViewNavigationViewModel: ObservableObject {
    @Published var isInfoViewPresented: InfoViewNavigationModel?
}

public struct InfoViewHolder: View {
    let title: String
    let description: String
    let type: InfoButtonType
    @StateObject var infoViewNavigationModel = InfoViewNavigationViewModel()
    @EnvironmentObject var router: Router

    public init(title: String, description: String, type: InfoButtonType = .regular) {
        self.title = title
        self.description = description
        self.type = type
    }

    public var body: some View {
        SwiftUI.Button {
            showInfoView()
        } label: {
            Image(uiImage: type.image)
                .foregroundColor(type.color)
        }
        .detent(
            item: $infoViewNavigationModel.isInfoViewPresented,
            style: [.height],
            options: .constant(.withoutGrabber)
        ) { freeTextPickerVm in
            InfoView(
                title: title,
                description: description
            )
        }
    }

    private func showInfoView() {
        let cancelAction = ReferenceAction {}

        infoViewNavigationModel.isInfoViewPresented = .init(
            title: title,
            description: description
        )

        cancelAction.execute = {
            router.dismiss()
        }
    }

    public enum InfoButtonType {
        case regular
        case navigation

        var image: UIImage {
            switch self {
            case .regular:
                hCoreUIAssets.infoFilled.image
            case .navigation:
                hCoreUIAssets.infoOutlined.image
            }
        }

        @hColorBuilder
        var color: some hColor {
            switch self {
            case .regular:
                hTextColor.Opaque.secondary
            case .navigation:
                hTextColor.Opaque.primary
            }
        }
    }
}

public struct InfoView: View {
    let title: String
    let description: String
    let extraButton: (text: String, style: hButtonConfigurationType, action: () -> Void)?
    @StateObject private var vm = InfoViewModel()

    public init(
        title: String,
        description: String,
        extraButton: (text: String, style: hButtonConfigurationType, action: () -> Void)? = nil
    ) {
        self.title = title
        self.description = description
        self.extraButton = extraButton
    }

    public var body: some View {
        hForm {
            hSection {
                VStack(alignment: .leading, spacing: .padding8) {
                    hText(title)
                    hText(description)
                        .foregroundColor(hTextColor.Opaque.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, .padding8)
                .padding(.top, .padding32)
            }
            .sectionContainerStyle(.transparent)
            .padding(.bottom, .padding24)
        }
        .hFormAttachToBottom {
            VStack(spacing: .padding8) {
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
                    vm.vc?.dismiss(animated: true)
                } content: {
                    hText(L10n.generalCloseButton)
                }
            }
            .padding(.horizontal, .padding24)
        }
        .introspect(.viewController, on: .iOS(.v13...)) { vc in
            vm.vc = vc
        }
    }
}

class InfoViewModel: ObservableObject {
    weak var vc: UIViewController?
}

struct InfoViewNavigationModel: Equatable, Identifiable {
    var id: String?

    static func == (lhs: InfoViewNavigationModel, rhs: InfoViewNavigationModel) -> Bool {
        return lhs.id == rhs.id
    }

    let title: String
    let description: String
    let extraButton: (text: String, style: hButtonConfigurationType, action: () -> Void)?
    @StateObject fileprivate var vm = InfoViewModel()

    public init(
        title: String,
        description: String,
        extraButton: (text: String, style: hButtonConfigurationType, action: () -> Void)? = nil
    ) {
        self.title = title
        self.description = description
        self.extraButton = extraButton
    }
}

import Foundation
import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect
import hCore

class InfoViewNavigationViewModel: ObservableObject {
    @Published var isInfoViewPresented = false
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
            type.image
                .foregroundColor(type.color)
        }
        .detent(
            presented: $infoViewNavigationModel.isInfoViewPresented,
            options: .constant(.withoutGrabber)
        ) {
            InfoView(
                title: title,
                description: description
            )
        }
    }

    private func showInfoView() {
        infoViewNavigationModel.isInfoViewPresented = true
    }

    @MainActor
    public enum InfoButtonType {
        case regular
        case navigation

        var image: some View {
            switch self {
            case .regular:
                hCoreUIAssets.infoFilled.view
            case .navigation:
                hCoreUIAssets.infoOutlined.view
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

public struct ExtraButtonModel {
    let text: String
    let style: hButtonConfigurationType
    let action: () -> Void

    public init(text: String, style: hButtonConfigurationType, action: @escaping () -> Void) {
        self.text = text
        self.style = style
        self.action = action
    }
}

public struct InfoView: View {
    let title: String?
    let description: String?
    let closeButtonTitle: String
    let extraButton: ExtraButtonModel?
    @StateObject private var vm = InfoViewModel()

    public init(
        title: String?,
        description: String?,
        closeButtonTitle: String = L10n.generalCloseButton,
        extraButton: ExtraButtonModel? = nil
    ) {
        self.title = title
        self.description = description
        self.closeButtonTitle = closeButtonTitle
        self.extraButton = extraButton
    }

    public var body: some View {
        hForm {
            hSection {
                VStack(alignment: .leading, spacing: .padding8) {
                    if let title {
                        hText(title)
                    }
                    if let description {
                        hText(description)
                            .foregroundColor(hTextColor.Opaque.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.horizontal, .padding8)
                .padding(.top, .padding32)
            }
            .sectionContainerStyle(.transparent)
            .padding(.bottom, .padding24)
        }
        .hFormContentPosition(.compact)
        .hFormAttachToBottom {
            VStack(spacing: .padding8) {
                if let button = extraButton {
                    if button.style != .alert {
                        hButton(
                            .large,
                            .primary,
                            content: .init(title: button.text),
                            {
                                button.action()
                            }
                        )
                    } else {
                        hButton(
                            .large,
                            .alert,
                            content: .init(title: button.text),
                            {
                                button.action()
                            }
                        )
                    }
                }
                hButton(
                    .large,
                    .ghost,
                    content: .init(title: closeButtonTitle),
                    {
                        vm.vc?.dismiss(animated: true)
                    }
                )
            }
            .padding(.horizontal, .padding24)
        }
        .introspect(.viewController, on: .iOS(.v13...)) { vc in
            vm.vc = vc
        }
    }
}

public struct InfoViewDataModel: Codable, Equatable, Identifiable, Hashable, Sendable {
    public var id: String?
    public let title: String?
    public let description: String?

    public init(
        id: String? = nil,
        title: String?,
        description: String?
    ) {
        self.id = id
        self.title = title
        self.description = description
    }
}

class InfoViewModel: ObservableObject {
    weak var vc: UIViewController?
}

extension View {
    public func addNavigationInfoButton(
        title: String,
        description: String
    ) -> some View {
        modifier(NavigationInfoButton(title: title, description: description))
    }
}

struct NavigationInfoButton: ViewModifier {
    let title: String
    let description: String
    @StateObject var vm = InfoButtonViewModel()

    init(
        title: String,
        description: String
    ) {
        self.title = title
        self.description = description
    }

    func body(content: Content) -> some View {
        content
            .introspect(.viewController, on: .iOS(.v13...)) { vc in
                let navBarItem = UIBarButtonItem(
                    image: hCoreUIAssets.infoOutlined.image,
                    style: .plain,
                    target: vm,
                    action: #selector(vm.transformDataToActivityView)
                )
                vc.navigationItem.leftBarButtonItem = navBarItem
            }
            .detent(
                presented: $vm.isInfoViewPresented,
                options: .constant(.withoutGrabber)
            ) {
                InfoView(
                    title: title,
                    description: description
                )
            }
    }
}

class InfoButtonViewModel: ObservableObject {
    @Published var isInfoViewPresented = false

    @objc func transformDataToActivityView() {
        isInfoViewPresented = true
    }
}

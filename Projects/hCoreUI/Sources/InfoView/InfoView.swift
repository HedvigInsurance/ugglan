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
    @EnvironmentObject var router: NavigationRouter

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
                infoViewModel: .init(
                    title: title,
                    description: description
                )
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

public struct InfoViewModel: Equatable, Identifiable {
    public var id: String? {
        title
    }
    let title: String?
    let description: String?
    let closeButtonTitle: String
    let actionOnClose: (() -> Void)?

    public init(
        title: String?,
        description: String?,
        closeButtonTitle: String = L10n.generalCloseButton,
        actionOnClose: (() -> Void)? = nil
    ) {
        self.title = title
        self.description = description
        self.closeButtonTitle = closeButtonTitle
        self.actionOnClose = actionOnClose
    }

    public static func == (lhs: InfoViewModel, rhs: InfoViewModel) -> Bool {
        lhs.title == rhs.title
    }
}

public struct InfoView: View {
    let infoViewModel: InfoViewModel
    @Environment(\.dismiss) private var dismiss

    public init(
        infoViewModel: InfoViewModel
    ) {
        self.infoViewModel = infoViewModel
    }

    public var body: some View {
        hForm {
            hSection {
                VStack(alignment: .leading, spacing: .padding8) {
                    if let title = infoViewModel.title {
                        hText(title)
                    }
                    if let description = infoViewModel.description {
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
                hButton(
                    .large,
                    .secondary,
                    content: .init(title: infoViewModel.closeButtonTitle)
                ) {
                    dismiss()
                    infoViewModel.actionOnClose?()
                }
            }
            .padding(.horizontal, .padding24)
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
                    infoViewModel: .init(
                        title: title,
                        description: description
                    )
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

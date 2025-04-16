import Foundation
import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect
import hCore

public enum ToolbarOptionType: Codable, Equatable, Sendable {
    case newOffer
    case firstVet
    case chat
    case chatNotification(lastMessageTimeStamp: Date?)
    case travelCertificate

    @MainActor
    var image: UIImage {
        switch self {
        case .newOffer:
            return hCoreUIAssets.campaignQuickNav.image
        case .firstVet:
            return hCoreUIAssets.firstVetQuickNav.image
        case .chat:
            return hCoreUIAssets.inbox.image
        case .chatNotification:
            return hCoreUIAssets.inboxNotification.image
        case .travelCertificate:
            return hCoreUIAssets.infoOutlined.image
        }
    }

    var displayName: String {
        switch self {
        case .newOffer:
            return L10n.InsuranceTab.CrossSells.title
        case .firstVet:
            return L10n.hcQuickActionsFirstvetTitle
        case .chat:
            return L10n.CrossSell.Info.faqChatButton
        case .chatNotification(let lastMessageTimeStamp):
            return "\(tooltipId)\(lastMessageTimeStamp ?? Date())"
        case .travelCertificate:
            return L10n.hcQuickActionsTravelCertificate
        }
    }

    var tooltipId: String {
        switch self {
        case .newOffer:
            return "newOfferHint"
        case .firstVet:
            return "firstVetHint"
        case .chat:
            return "chatHint"
        case .chatNotification:
            return "chatHintNotification"
        case .travelCertificate:
            return "travelCertHint"
        }
    }

    var identifiableId: String {
        switch self {
        case .chatNotification(let lastMessageTimeStamp):
            return "\(tooltipId)\(lastMessageTimeStamp ?? Date())"
        default:
            return tooltipId
        }
    }

    var textToShow: String? {
        switch self {
        case .newOffer:
            return nil
        case .firstVet:
            return nil
        case .chat:
            return L10n.HomeTab.chatHintText
        case .chatNotification:
            return L10n.Toast.newMessage
        case .travelCertificate:
            return L10n.Toast.readMore
        }
    }

    var showAsTooltip: Bool {
        switch self {
        case .newOffer, .firstVet:
            return false
        default:
            return true
        }
    }

    var timeIntervalForShowingAgain: TimeInterval? {
        switch self {
        case .chat:
            return .days(numberOfDays: 30)
        case .chatNotification:
            return 30
        case .travelCertificate:
            return 60
        default:
            return nil
        }
    }

    var delay: TimeInterval {
        switch self {
        case .chat:
            return 1.5
        case .chatNotification, .travelCertificate:
            return 0.5
        default:
            return 0
        }
    }

    func shouldShowTooltip(for timeInterval: TimeInterval) -> Bool {
        switch self {
        case .chat:
            if let pastDate = UserDefaults.standard.value(forKey: userDefaultsKey) as? Date {
                let timeIntervalSincePast = abs(
                    pastDate.timeIntervalSince(Date())
                )

                if timeIntervalSincePast > timeInterval {
                    onShow()
                    return true
                }

                return false
            }
            onShow()
            return true
        case .chatNotification(let lastMessageTimeStamp):
            guard let lastMessageTimeStamp else { return false }
            if let pastDate = UserDefaults.standard.value(forKey: userDefaultsKey) as? Date {
                if pastDate < lastMessageTimeStamp {
                    onShow()
                    return true
                }
                return false
            }
            onShow()
            return true
        case .travelCertificate:
            if let pastDate = UserDefaults.standard.value(forKey: userDefaultsKey) as? Date {
                let timeIntervalSincePast = abs(
                    pastDate.timeIntervalSince(Date())
                )

                if timeIntervalSincePast > timeInterval {
                    onShow()
                    return true
                }
                return false
            }
            onShow()
            return true
        default:
            return false
        }
    }

    var imageSize: CGFloat {
        switch self {
        case .travelCertificate:
            return 24
        default:
            return 40
        }
    }

    @hColorBuilder @MainActor
    var tooltipColor: some hColor {
        switch self {
        case .travelCertificate:
            hFillColor.Opaque.primary
        default:
            hFillColor.Opaque.secondary
        }
    }

    func onShow() {
        switch self {
        case .chat:
            UserDefaults.standard.setValue(Date(), forKey: userDefaultsKey)
        case .chatNotification(let lastMessageTimeStamp):
            UserDefaults.standard.setValue(lastMessageTimeStamp, forKey: userDefaultsKey)
        case .travelCertificate:
            UserDefaults.standard.setValue(Date(), forKey: userDefaultsKey)
        default:
            break
        }
    }

    var userDefaultsKey: String {
        "tooltip_\(tooltipId)_past_date"
    }

}

public struct ToolbarButtonView: View {
    @State var displayTooltip = false
    var action: ((_: ToolbarOptionType)) -> Void
    @Binding var types: [ToolbarOptionType]
    let placement: ListToolBarPlacement
    private var spacing: CGFloat {
        if #available(iOS 18.0, *) {
            return 0
        } else {
            return -8
        }
    }

    public init(
        types: Binding<[ToolbarOptionType]>,
        placement: ListToolBarPlacement,
        action: @escaping (_: ToolbarOptionType) -> Void,
    ) {
        self._types = types
        self.placement = placement
        self.action = action
    }

    public var body: some View {
        HStack(spacing: spacing) {
            ForEach(Array(types.enumerated()), id: \.element.identifiableId) { index, type in
                VStack(alignment: .trailing) {
                    SwiftUI.Button(action: {
                        withAnimation(.spring()) {
                            displayTooltip = false
                        }
                        action(type)
                    }) {
                        Image(uiImage: type.image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: type.imageSize, height: type.imageSize)
                            .foregroundColor(hFillColor.Opaque.primary)
                            .shadow(color: .black.opacity(0.15), radius: 1, x: 0, y: 1)
                            .accessibilityValue(type.displayName)
                    }
                }
                .background(tooltipView(for: type))
            }
        }
    }

    private func tooltipView(for type: ToolbarOptionType) -> some View {
        VStack {
            if type.showAsTooltip {
                TooltipView(
                    displayTooltip: $displayTooltip,
                    type: type,
                    timeInterval: type.timeIntervalForShowingAgain ?? .days(numberOfDays: 30),
                    placement: placement
                )
                .position(x: xOffset(for: type), y: yOffset(for: type))
                .fixedSize()
            }
        }
    }

    private func xOffset(for type: ToolbarOptionType) -> CGFloat {
        switch type {
        case .travelCertificate:
            if placement == .leading {
                return 76
            }
            return 22
        default:
            return 26
        }
    }

    private func yOffset(for type: ToolbarOptionType) -> CGFloat {
        switch type {
        case .travelCertificate:
            return 50
        default:
            return 55
        }
    }
}

public struct ToolbarViewModifier<Leading: View, Trailing: View>: ViewModifier {
    let action: (_: ToolbarOptionType) -> Void
    @StateObject var navVm = ToolbarButtonsViewModifierViewModel()
    @Binding var types: [ToolbarOptionType]
    let vcName: String?
    let placement: ListToolBarPlacement

    let leading: Leading?
    let trailing: Trailing?
    let showLeading: Bool
    let showTrailing: Bool

    public init(
        leading: Leading?,
        trailing: Trailing?,
        showLeading: Bool,
        showTrailing: Bool
    ) {
        self.leading = leading
        self.trailing = trailing
        self.showLeading = showLeading
        self.showTrailing = showTrailing
        self.placement = leading == nil ? .trailing : .leading
        self.action = { _ in }
        self.vcName = nil
        self._types = .constant([])
    }

    public init(
        action: @escaping (_: ToolbarOptionType) -> Void,
        types: Binding<[ToolbarOptionType]>,
        vcName: String,
        placement: ListToolBarPlacement
    ) {
        self.action = action
        self._types = types
        self.vcName = vcName
        self.placement = placement
        self.leading = nil
        self.trailing = nil
        self.showLeading = false
        self.showTrailing = false
    }

    public func body(content: Content) -> some View {
        if #available(iOS 18.0, *) {
            content
                .introspect(.viewController, on: .iOS(.v18...)) { @MainActor vc in
                    if let nav = vc.navigationController {
                        if self.navVm.nav != nav {
                            self.navVm.nav = nav
                            setNavigation(vc)
                        }
                    }
                }
                .onChange(of: types) { value in
                    setNavigation()
                }

        } else {
            if let leading, showLeading {
                content
                    .navigationBarItems(
                        leading:
                            leading
                    )
            } else {
                let toolbarView = ToolbarButtonView(types: $types, placement: placement, action: action)
                content
                    .navigationBarItems(
                        trailing:
                            trailing != nil && showTrailing ? trailing?.asAnyView : toolbarView.asAnyView
                    )
            }
        }
    }

    private func setNavigation(_ vc: UIViewController? = nil) {
        if let leading, let vc = vc, showLeading {
            setView(for: leading, vc: vc, placement: .leading)
        }
        if let trailing, let vc = vc, showTrailing {
            setView(for: trailing, vc: vc, placement: .trailing)
        } else {
            if let vc = self.navVm.nav?.viewControllers.first(where: { $0.debugDescription == vcName }) {
                let viewToInject = ToolbarButtonView(types: $types, placement: placement, action: action)
                setView(for: viewToInject, vc: vc, placement: placement)
            }
        }
    }

    private func setView(for view: any View, vc: UIViewController, placement: ListToolBarPlacement) {
        let hostingVc = UIHostingController(rootView: view.asAnyView)
        let viewToPlace = hostingVc.view!
        viewToPlace.backgroundColor = .clear
        if placement == .leading {
            vc.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: viewToPlace)
        } else {
            vc.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: viewToPlace)
        }
    }
}

class ToolbarButtonsViewModifierViewModel: ObservableObject {
    weak var nav: UINavigationController?
}

extension TimeInterval {
    public static func days(numberOfDays: Int) -> TimeInterval {
        Double(numberOfDays) * 24 * 60 * 60
    }

}

extension View {
    public func setHomeNavigationBars(
        with options: Binding<[ToolbarOptionType]>,
        and vcName: String,
        action: @escaping (_: ToolbarOptionType) -> Void
    ) -> some View {
        ModifiedContent(
            content: self,
            modifier: ToolbarViewModifier<EmptyView, EmptyView>(
                action: action,
                types: options,
                vcName: vcName,
                placement: .trailing
            )
        )
    }

    public func setToolbar<Leading: View, Trailing: View>(
        @ViewBuilder _ leading: () -> Leading,
        @ViewBuilder _ trailing: () -> Trailing
    ) -> some View {
        self.modifier(
            ToolbarViewModifier(
                leading: leading(),
                trailing: trailing(),
                showLeading: true,
                showTrailing: true
            )
        )
    }

    public func setToolbarLeading<Leading: View>(
        @ViewBuilder content leading: () -> Leading
    ) -> some View {
        self.modifier(
            ToolbarViewModifier(
                leading: leading(),
                trailing: EmptyView(),
                showLeading: true,
                showTrailing: false
            )
        )
    }

    public func setToolbarTrailing<Trailing: View>(
        @ViewBuilder _ trailing: () -> Trailing
    ) -> some View {
        self.modifier(
            ToolbarViewModifier(
                leading: EmptyView(),
                trailing: trailing(),
                showLeading: false,
                showTrailing: true
            )
        )
    }
}

public enum ListToolBarPlacement {
    case trailing
    case leading
}

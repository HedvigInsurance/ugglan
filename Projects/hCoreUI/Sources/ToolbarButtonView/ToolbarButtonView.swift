import Foundation
import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect

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
        _types = types
        self.placement = placement
        self.action = action
    }

    public var body: some View {
        HStack(spacing: spacing) {
            ForEach(Array(types.enumerated()), id: \.element.identifiableId) { _, type in
                VStack(alignment: .trailing) {
                    SwiftUI.Button(action: {
                        withAnimation(.spring()) {
                            displayTooltip = false
                        }
                        action(type)
                    }) {
                        ZStack(alignment: .topTrailing) {
                            if type.shouldAnimate {
                                imageFor(type: type)
                                    .rotate()
                            } else {
                                imageFor(type: type)
                            }
                            if type.showBadge {
                                Circle()
                                    .fill(hSignalColor.Red.element)
                                    .frame(width: 10, height: 10)
                                    .offset(x: -.padding4, y: .padding4)
                                    .accessibilityHidden(true)
                            }
                        }
                    }
                    .accessibilityLabel(type.displayName)
                }
                .showTooltip(type: type, placement: placement)
            }
        }
    }

    private func imageFor(type: ToolbarOptionType) -> some View {
        Image(uiImage: type.image)
            .resizable()
            .scaledToFill()
            .accessibilityHidden(true)
            .frame(width: type.imageSize, height: type.imageSize)
            .foregroundColor(hFillColor.Opaque.primary)
            .shadow(color: type.shadowColor, radius: 1, x: 0, y: 1)
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
        placement = leading == nil ? .trailing : .leading
        action = { _ in }
        vcName = nil
        _types = .constant([])
    }

    public init(
        action: @escaping (_: ToolbarOptionType) -> Void,
        types: Binding<[ToolbarOptionType]>,
        vcName: String,
        placement: ListToolBarPlacement
    ) {
        self.action = action
        _types = types
        self.vcName = vcName
        self.placement = placement
        leading = nil
        trailing = nil
        showLeading = false
        showTrailing = false
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
                .onChange(of: types) { _ in
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
            if let vc = navVm.nav?.viewControllers.first(where: { $0.debugDescription == vcName }) {
                let viewToInject = ToolbarButtonView(types: $types, placement: placement, action: action)
                setView(for: viewToInject, vc: vc, placement: placement)
            }
        }
    }

    private func setView(for view: any View, vc: UIViewController, placement: ListToolBarPlacement) {
        let hostingVc = UIHostingController(rootView: view.asAnyView)
        let viewToPlace = hostingVc.view!
        viewToPlace.backgroundColor = .clear
        let uiBarButtonItem = UIBarButtonItem(customView: viewToPlace)
        if placement == .leading {
            vc.navigationItem.leftBarButtonItem = uiBarButtonItem
        } else {
            vc.navigationItem.rightBarButtonItem = uiBarButtonItem
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
        modifier(
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
        modifier(
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
        modifier(
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

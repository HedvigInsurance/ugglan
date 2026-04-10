import Foundation
import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect
import hCore

public struct ToolbarButtonView: View {
    @State var displayTooltip = false
    var action: ((_: ToolbarOptionType)) -> Void
    let type: ToolbarOptionType
    let placement: ListToolBarPlacement
    let useSpacing: Bool
    private var leadingSpacing: CGFloat {
        if #available(iOS 26.0, *) {
            return 0
        } else {
            return -.padding12
        }
    }
    private var trailingSpacing: CGFloat {
        if #available(iOS 26.0, *) {
            return 0
        } else {
            return -.padding4
        }
    }

    public init(
        type: ToolbarOptionType,
        placement: ListToolBarPlacement,
        action: @escaping (_: ToolbarOptionType) -> Void,
        useSpacing: Bool = false
    ) {
        self.type = type
        self.placement = placement
        self.action = action
        self.useSpacing = useSpacing
    }

    public var body: some View {
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
                    if #unavailable(iOS 26.0), type.showBadge {
                        Circle()
                            .fill(hSignalColor.Red.element)
                            .frame(width: 10, height: 10)
                            .offset(x: -.padding4, y: .padding4)
                    }
                }
            }
            .padding(.leading, useSpacing ? leadingSpacing : 0)
            .padding(.trailing, useSpacing ? trailingSpacing : 0)
        }
        .showTooltip(type: type, placement: placement)
    }

    private func imageFor(type: ToolbarOptionType) -> some View {
        type.image
            .resizable()
            .scaledToFill()
            .accessibilityHidden(true)
            .frame(width: type.imageSize, height: type.imageSize)
            .foregroundColor(type.imageTintColor)
            .shadow(color: type.shadowColor, radius: 1, x: 0, y: 1)
            .accessibilityValue(type.accessibilityDisplayName)
    }
}

public struct ToolbarViewModifier<Leading: View, Trailing: View>: ViewModifier {
    let action: (_: ToolbarOptionType) -> Void
    @StateObject var navVm = ToolbarButtonsViewModifierViewModel()
    @Binding var types: [ToolbarOptionType]
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
        _types = .constant([])
    }

    public init(
        action: @escaping (_: ToolbarOptionType) -> Void,
        types: Binding<[ToolbarOptionType]>,
        placement: ListToolBarPlacement
    ) {
        self.action = action
        _types = types
        self.placement = placement
        leading = nil
        trailing = nil
        showLeading = false
        showTrailing = false
    }

    public func body(content: Content) -> some View {
        if let leading, showLeading {
            content
                .toolbar {
                    ToolbarItem(
                        placement: .topBarLeading
                    ) {
                        leading
                    }
                }
        } else if let trailing {
            content
                .toolbar {
                    ToolbarItem(
                        placement: .topBarTrailing
                    ) {
                        trailing
                    }
                }
            // had to do it like this so each item is seperated for iOS 26
        } else if #available(iOS 26.0, *), types.count > 0 {
            content
                .introspect(.viewController, on: .iOS(.v13...)) { @MainActor [weak navVm] vc in
                    guard let navVm else { return }
                    if navVm.viewController != vc {
                        navVm.viewController = vc
                        setNavigationBarItemsUsingTypes(for: vc)
                    }
                }
                .onChange(of: types) { [weak navVm] _ in
                    if let vc = navVm?.viewController {
                        setNavigationBarItemsUsingTypes(for: vc)
                    }
                }
        } else {
            content
                .toolbar {
                    ToolbarTrailingItems(types: types, placement: placement, action: action)
                }
        }
    }

    //used for iOS 26 to have items splited
    private func setNavigationBarItemsUsingTypes(for vc: UIViewController) {
        var buttonItems = [UIBarButtonItem]()
        for (index, type) in types.reversed().enumerated() {
            let viewToInject = ToolbarButtonView(type: type, placement: placement, action: action)
            let hostingVc = UIHostingController(rootView: viewToInject.asAnyView)
            let viewToPlace = hostingVc.view!
            viewToPlace.backgroundColor = .clear
            let uiBarButtonItem = UIBarButtonItem(customView: viewToPlace)
            buttonItems.append(uiBarButtonItem)
            if #available(iOS 26.0, *) {
                if type.showBadge {
                    var badge: UIBarButtonItem.Badge = .string("'")
                    badge.foregroundColor = UIColor.red
                    badge.backgroundColor = UIColor.red
                    badge.font = .systemFont(ofSize: 5)
                    uiBarButtonItem.badge = badge
                }
            }
            if index < types.count {
                if #available(iOS 26.0, *) {
                    buttonItems.append(.fixedSpace())
                }
            }
        }
        if placement == .leading {
            vc.navigationItem.setLeftBarButtonItems(buttonItems, animated: false)
        } else {
            vc.navigationItem.setRightBarButtonItems(buttonItems, animated: false)
        }
    }
}

private struct ToolbarTrailingItems: ToolbarContent {
    let types: [ToolbarOptionType]
    let placement: ListToolBarPlacement
    let action: (_: ToolbarOptionType) -> Void

    var body: some ToolbarContent {
        if types.indices.contains(0) {
            ToolbarItem(placement: .topBarTrailing) {
                ToolbarButtonView(type: types[0], placement: placement, action: action, useSpacing: true)
            }
        }
        if types.indices.contains(1) {
            ToolbarItem(placement: .topBarTrailing) {
                ToolbarButtonView(type: types[1], placement: placement, action: action, useSpacing: true)
            }
        }
        if types.indices.contains(2) {
            ToolbarItem(placement: .topBarTrailing) {
                ToolbarButtonView(type: types[2], placement: placement, action: action, useSpacing: true)
            }
        }
        if types.indices.contains(3) {
            ToolbarItem(placement: .topBarTrailing) {
                ToolbarButtonView(type: types[3], placement: placement, action: action, useSpacing: true)
            }
        }
        if types.indices.contains(4) {
            ToolbarItem(placement: .topBarTrailing) {
                ToolbarButtonView(type: types[4], placement: placement, action: action, useSpacing: true)
            }
        }
    }
}

class ToolbarButtonsViewModifierViewModel: ObservableObject {
    weak var viewController: UIViewController?
}

extension TimeInterval {
    public static func days(numberOfDays: Int) -> TimeInterval {
        Double(numberOfDays) * 24 * 60 * 60
    }
}

extension View {
    public func setHomeNavigationBars(
        with options: Binding<[ToolbarOptionType]>,
        action: @escaping (_: ToolbarOptionType) -> Void
    ) -> some View {
        ModifiedContent(
            content: self,
            modifier: ToolbarViewModifier<EmptyView, EmptyView>(
                action: action,
                types: options,
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

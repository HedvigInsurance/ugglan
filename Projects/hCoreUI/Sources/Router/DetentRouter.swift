import Combine
import Foundation
import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect
import hCore

@preconcurrency
public enum TransitionType: Equatable {
    case detent(style: [Detent])
    case center
}

extension View {
    public func detent<SwiftUIContent: View>(
        presented: Binding<Bool>,
        transitionType: TransitionType? = .detent(style: [.height]),
        options: Binding<DetentPresentationOption>? = .constant([]),
        onUserDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> SwiftUIContent
    ) -> some View {
        modifier(
            DetentSizeModifier(
                presented: presented,
                transitionType: transitionType ?? .detent(style: [.height]),
                options: options ?? .constant([]),
                onUserDismiss: onUserDismiss,
                content: content
            )
        )
    }

    public func detent<Item, Content>(
        item: Binding<Item?>,
        transitionType: TransitionType? = .detent(style: [.height]),
        options: Binding<DetentPresentationOption>? = .constant([]),
        onUserDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping (Item) -> Content
    ) -> some View where Item: Identifiable & Equatable, Content: View {
        modifier(
            DetentSizeModifierModal(
                item: item,
                transitionType: transitionType ?? .detent(style: [.height]),
                options: options ?? .constant([]),
                onUserDismiss: onUserDismiss,
                content: content
            )
        )
    }
}

private struct DetentSizeModifierModal<Item, SwiftUIContent>: ViewModifier
where SwiftUIContent: View, Item: Identifiable & Equatable {
    @Binding var item: Item?
    @State var itemToRenderFrom: Item?
    @State var present: Bool = false
    let transitionType: TransitionType
    @Binding var options: DetentPresentationOption
    let onUserDismiss: (() -> Void)?
    var content: (Item) -> SwiftUIContent

    func body(content: Content) -> some View {
        Group {
            content.detent(
                presented: $present,
                transitionType: transitionType,
                options: $options,
                onUserDismiss: onUserDismiss
            ) {
                if let item = itemToRenderFrom {
                    self.content(item)
                }
            }
        }
        .onAppear {
            if let item = item {
                itemToRenderFrom = item
            }
            present = item != nil
        }
        .onChange(of: item) { newValue in
            if let item = item {
                itemToRenderFrom = item
            }
            present = newValue != nil
        }
        .onChange(of: present) { _ in
            if !present {
                item = nil
            }
        }
    }
}

private struct DetentSizeModifier<SwiftUIContent>: ViewModifier where SwiftUIContent: View {
    @Binding var presented: Bool
    let content: () -> SwiftUIContent
    let transitionType: TransitionType
    @Binding var options: DetentPresentationOption
    @StateObject private var presentationViewModel = PresentationViewModel()
    let onUserDismiss: (() -> Void)?

    init(
        presented: Binding<Bool>,
        transitionType: TransitionType,
        options: Binding<DetentPresentationOption>,
        onUserDismiss: (() -> Void)?,
        @ViewBuilder content: @escaping () -> SwiftUIContent
    ) {
        _presented = presented
        self.content = content
        self.transitionType = transitionType
        _options = options
        self.onUserDismiss = onUserDismiss
    }

    @ViewBuilder
    func body(content: Content) -> some View {
        content
            .introspect(.viewController, on: .iOS(.v13...)) { vc in
                presentationViewModel.rootVC = vc
            }
            .onAppear {
                handle(isPresent: presented)
            }
            .onChange(of: presented) { isPresent in
                handle(isPresent: isPresent)
            }
    }

    private func handle(isPresent: Bool) {
        if isPresent {
            var withDelay = false
            if options.contains(.alwaysOpenOnTop) {
                // if we want to always open on top, we check if the top VC is being dismissed
                // and if so, we wait a bit before presenting the new VC to avoid UI glitches
                if UIApplication.shared.getTopViewController()?.isBeingDismissed == true {
                    withDelay = true
                }
            } else if let presentedVC = presentationViewModel.rootVC?.presentedViewController {
                // if we don't want to always open on top, we check if rootVC is presenting some VC and dismiss it
                // also add some delay to avoid UI glitches
                presentedVC.dismiss(animated: true)
                withDelay = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + (withDelay ? 0.8 : 0)) {
                if case let .detent(style) = transitionType {
                    presentationViewModel.style = style
                }

                let vcToPresent = getPresentationTarget()
                let content = getContent()

                let vc = hHostingController(rootView: content)
                if isLiquidGlassEnabled {
                    vc.view.backgroundColor = .clear
                }
                var shouldUseBlur: Bool {
                    if case let .detent(style) = transitionType {
                        return style.contains(.height)
                    }
                    return false
                }

                let delegate = getDelegate(for: vc, shouldUseBlur: shouldUseBlur)
                vc.transitioningDelegate = delegate
                vc.modalPresentationStyle = .custom
                vc.onDeinit = {
                    Task { @MainActor in
                        presented = false
                    }
                }

                vc.onDismiss = {
                    Task { @MainActor in
                        presented = false
                        presentationViewModel.presentingVC = nil
                    }
                }

                presentationViewModel.presentingVC = vc
                UIAccessibility.post(notification: .screenChanged, argument: vc.view)
                vcToPresent?
                    .present(
                        vc,
                        animated: true,
                        completion: { [weak vc] in
                            Task {
                                UIAccessibility.post(notification: .screenChanged, argument: vc?.view)
                            }
                        }
                    )
            }
        } else {
            presentationViewModel.presentingVC?.dismiss(animated: true)
        }
    }

    @ViewBuilder
    private func getContent() -> some View {
        if transitionType == .center {
            content()
                .clipShape(RoundedRectangle(cornerRadius: .cornerRadiusXL))
                .hShadow(type: .custom(opacity: 0.05, radius: 5, xOffset: 0, yOffset: 4))
                .hShadow(type: .custom(opacity: 0.1, radius: 1, xOffset: 0, yOffset: 2))
        } else {
            content()
        }
    }

    private func getPresentationTarget() -> UIViewController? {
        if options.contains(.alwaysOpenOnTop) {
            let vc = UIApplication.shared.getTopViewController()
            if vc?.isBeingDismissed == true {
                return vc?.presentingViewController
            }
            return vc
        } else {
            return presentationViewModel.rootVC ?? UIApplication.shared.getTopViewController()
        }
    }

    private func getDelegate(
        for vc: UIViewController,
        shouldUseBlur: Bool
    ) -> (any UIViewControllerTransitioningDelegate) {
        switch transitionType {
        case let .detent(style):
            let delegate = DetentTransitioningDelegate(
                detents: style,
                options: shouldUseBlur ? [PresentationOptions.useBlur] : [],
                wantsGrabber: options.contains(.withoutGrabber) ? false : true,
                viewController: vc
            )
            vc.isModalInPresentation = options.contains(.disableDismissOnScroll)
            return delegate
        case .center:
            let delegate = CenteredModalTransitioningDelegate(
                bottomView: closeButton.asAnyView,
                onUserDismiss: onUserDismiss
            )
            vc.view.backgroundColor = .clear
            vc.isModalInPresentation = options.contains(.disableDismissOnScroll)
            return delegate
        }
    }

    private var closeButton: some View {
        hSection {
            hCloseButton { [self] in
                onUserDismiss?()
                presentationViewModel.presentingVC?.dismiss(animated: true)
            }
        }
        .sectionContainerStyle(.transparent)
    }
}

@MainActor
class PresentationViewModel: ObservableObject {
    weak var rootVC: UIViewController?
    var style: [Detent] = []
    weak var presentingVC: UIViewController? {
        didSet {
            if style.contains(.height) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
                    let allScrollViewDescendants = self?.presentingVC?.view.allDescendants(ofType: UIScrollView.self)

                    if let scrollView = allScrollViewDescendants?
                        .first(where: { _ in
                            true
                        })
                    {
                        self?.formContentSizeChanged =
                            scrollView
                            .publisher(for: \.contentSize)
                            .map {
                                $0.height.rounded()
                            }
                            .removeDuplicates()
                            .throttle(for: .milliseconds(100), scheduler: RunLoop.main, latest: true)
                            .sink(receiveValue: { _ in
                                guard let self else { return }
                                if #available(iOS 16.0, *) {
                                    self.presentingVC?.sheetPresentationController?
                                        .animateChanges {
                                            self.presentingVC?.sheetPresentationController?
                                                .invalidateDetents()
                                        }
                                } else {
                                    self.presentingVC?.sheetPresentationController?
                                        .animateChanges {}
                                }
                            })
                    }
                }
            }
        }
    }

    private var formContentSizeChanged: AnyCancellable?
}

@MainActor
public struct DetentPresentationOption: OptionSet, Sendable {
    public let rawValue: UInt
    public static let alwaysOpenOnTop = DetentPresentationOption(rawValue: 1 << 0)
    public static let withoutGrabber = DetentPresentationOption(rawValue: 1 << 2)
    public static let disableDismissOnScroll = DetentPresentationOption(rawValue: 1 << 3)

    public nonisolated init(rawValue: UInt) {
        self.rawValue = rawValue
    }
}

@MainActor public var logStartView: ((_ key: String, _ name: String) -> Void) = { _, _ in }
@MainActor public var logStopView: ((_ key: String) -> Void) = { _ in }

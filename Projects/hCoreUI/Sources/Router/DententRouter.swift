import Combine
import Foundation
import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect
import hCore

public enum TransitionType: Equatable {
    case detent(style: [Detent])
    case pageSheet
}

extension View {
    public func detent<SwiftUIContent: View>(
        presented: Binding<Bool>,
        transitionType: TransitionType,
        options: Binding<DetentPresentationOption> = .constant([]),
        @ViewBuilder content: @escaping () -> SwiftUIContent
    ) -> some View {
        modifier(
            DetentSizeModifier(
                presented: presented,
                transitionType: transitionType,
                options: options,
                content: content
            )
        )
    }

    public func detent<Item, Content>(
        item: Binding<Item?>,
        transitionType: TransitionType,
        options: Binding<DetentPresentationOption> = .constant([]),
        @ViewBuilder content: @escaping (Item) -> Content
    ) -> some View where Item: Identifiable & Equatable, Content: View {
        return modifier(
            DetentSizeModifierModal(
                item: item,
                transitionType: transitionType,
                options: options,
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
    var content: (Item) -> SwiftUIContent

    func body(content: Content) -> some View {
        Group {
            content.detent(presented: $present, transitionType: transitionType, options: $options) {
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
        .onChange(of: present) { newValue in
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
    init(
        presented: Binding<Bool>,
        transitionType: TransitionType,
        options: Binding<DetentPresentationOption>,
        @ViewBuilder content: @escaping () -> SwiftUIContent
    ) {
        _presented = presented
        self.content = content
        self.transitionType = transitionType
        self._options = options
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
            if !options.contains(.alwaysOpenOnTop) {
                if let presentedVC = presentationViewModel.rootVC?.presentedViewController {
                    presentedVC.dismiss(animated: true)
                    withDelay = true
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + (withDelay ? 0.8 : 0)) {
                if case .detent(let style) = transitionType {
                    presentationViewModel.style = style
                }

                let vcToPresent = self.getPresentationTarget()

                let content = self.content()
                let vc = hHostingController(
                    rootView: content
                )

                var shouldUseBlur: Bool {
                    if case .detent(let style) = transitionType {
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
                presentationViewModel.presentingVC = vc
                vcToPresent?.present(vc, animated: true)
            }
        } else {
            presentationViewModel.presentingVC?.dismiss(animated: true)
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
        case .detent:
            let delegate = DetentTransitioningDelegate(
                detents: transitionType,
                options: shouldUseBlur ? [PresentationOptions.useBlur] : [],
                wantsGrabber: options.contains(.withoutGrabber) ? false : true,
                viewController: vc
            )

            if options.contains(.disableDismissOnScroll) {
                vc.isModalInPresentation = true
            } else {
                vc.isModalInPresentation = false
            }
            return delegate
        case .pageSheet:
            let delegate = CenteredModalTransitioningDelegate()
            presentationViewModel.transitionDelegate = delegate
            vc.isModalInPresentation = options.contains(.disableDismissOnScroll)
            return delegate
        }
    }

}

//private struct PageSheetSizeModifier<SwiftUIContent>: ViewModifier where SwiftUIContent: View {
//    @Binding var presented: Bool
//    let content: () -> SwiftUIContent
//    private let style: [Detent]
//    @Binding var options: DetentPresentationOption
//    @StateObject private var presentationViewModel = PageSheetPresentationViewModel()
//
//    init(
//        presented: Binding<Bool>,
//        style: [Detent],
//        options: Binding<DetentPresentationOption>,
//        @ViewBuilder content: @escaping () -> SwiftUIContent
//    ) {
//        _presented = presented
//        self.content = content
//        self.style = style
//        self._options = options
//    }
//
//    func body(content: Content) -> some View {
//        content
//            .introspect(.viewController, on: .iOS(.v13...)) { vc in
//                presentationViewModel.rootVC = vc
//            }
//            .onAppear { handle(isPresent: presented) }
//            .onChange(of: presented) { isPresent in handle(isPresent: isPresent) }
//    }
//
//    private func handle(isPresent: Bool) {
//        if isPresent {
//            var withDelay = false
//            if !options.contains(.alwaysOpenOnTop) {
//                if let presentedVC = presentationViewModel.rootVC?.presentedViewController {
//                    presentedVC.dismiss(animated: true)
//                    withDelay = true
//                }
//            }
//
//            DispatchQueue.main.asyncAfter(deadline: .now() + (withDelay ? 0.8 : 0)) {
//                presentationViewModel.style = style
//                let vcToPresent = getPresentationTarget()
//                let content = self.content()
//                let vc = hHostingController(rootView: content)
//
//                let delegate = CenteredModalTransitioningDelegate()
//                presentationViewModel.transitionDelegate = delegate
//                vc.transitioningDelegate = delegate
//                vc.modalPresentationStyle = .custom
//                vc.isModalInPresentation = options.contains(.disableDismissOnScroll)
//
//                vc.onDeinit = {
//                    Task { @MainActor in
//                        presented = false
//                    }
//                }
//
//                if let presentingVC = vcToPresent {
//                    presentingVC.present(vc, animated: true)
//                } else {
//                    assertionFailure("No valid view controller to present from.")
//                }
//            }
//        } else {
//            presentationViewModel.presentingVC?.dismiss(animated: true)
//        }
//    }
//
//    private func getPresentationTarget() -> UIViewController? {
//        if options.contains(.alwaysOpenOnTop) {
//            let vc = UIApplication.shared.getTopViewController()
//            return vc?.isBeingDismissed == true ? vc?.presentingViewController : vc
//        } else {
//            return presentationViewModel.rootVC ?? UIApplication.shared.getTopViewController()
//        }
//    }
//}

@MainActor
class PresentationViewModel: ObservableObject {
    weak var rootVC: UIViewController?
    var style: [Detent] = []
    var transitionDelegate: UIViewControllerTransitioningDelegate?
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
                            .sink(receiveValue: { value in
                                guard let self else { return }
                                if #available(iOS 16.0, *) {
                                    self.presentingVC?.sheetPresentationController?
                                        .animateChanges {
                                            self.presentingVC?.sheetPresentationController?
                                                .invalidateDetents()
                                        }
                                } else {
                                    self.presentingVC?.sheetPresentationController?
                                        .animateChanges {

                                        }
                                }
                            })
                    }
                }
            }
        }
    }
    private var formContentSizeChanged: AnyCancellable?
}

extension UIViewController {
    var className: String {
        String(describing: Self.self)
    }
}

@MainActor
public struct DetentPresentationOption: OptionSet, Sendable {
    public let rawValue: UInt
    public static let alwaysOpenOnTop = DetentPresentationOption(rawValue: 1 << 0)
    public static let withoutGrabber = DetentPresentationOption(rawValue: 1 << 2)
    public static let disableDismissOnScroll = DetentPresentationOption(rawValue: 1 << 3)
    public static let withBannerOnTop = DetentPresentationOption(rawValue: 1 << 4)

    nonisolated public init(rawValue: UInt) {
        self.rawValue = rawValue
    }

}

@MainActor public var logStartView: ((_ key: String, _ name: String) -> Void) = { _, _ in }
@MainActor public var logStopView: ((_ key: String) -> Void) = { _ in }

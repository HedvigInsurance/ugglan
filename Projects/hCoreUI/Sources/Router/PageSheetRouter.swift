import Combine
import Foundation
import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect
import hCore

extension View {
    public func pageSheet<SwiftUIContent: View>(
        presented: Binding<Bool>,
        style: [Detent],
        options: Binding<DetentPresentationOption> = .constant([]),
        @ViewBuilder content: @escaping () -> SwiftUIContent
    ) -> some View {
        modifier(
            PageSheetSizeModifier(
                presented: presented,
                style: style,
                options: options,
                content: content
            )
        )
    }

    public func pageSheet<Item, Content>(
        item: Binding<Item?>,
        style: [Detent],
        options: Binding<DetentPresentationOption> = .constant([]),
        @ViewBuilder content: @escaping (Item) -> Content
    ) -> some View where Item: Identifiable & Equatable, Content: View {
        modifier(
            PageSheetSizeModifierModal(item: item, style: style, options: options, content: content)
        )
    }
}

private struct PageSheetSizeModifierModal<Item, SwiftUIContent>: ViewModifier
where SwiftUIContent: View, Item: Identifiable & Equatable {
    @Binding var item: Item?
    @State var itemToRenderFrom: Item?
    @State var present: Bool = false
    let style: [Detent]
    @Binding var options: DetentPresentationOption
    var content: (Item) -> SwiftUIContent

    func body(content: Content) -> some View {
        Group {
            content.pageSheet(presented: $present, style: style, options: $options) {
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

private struct PageSheetSizeModifier<SwiftUIContent>: ViewModifier where SwiftUIContent: View {
    @Binding var presented: Bool
    let content: () -> SwiftUIContent
    private let style: [Detent]
    @Binding var options: DetentPresentationOption
    @StateObject private var presentationViewModel = PageSheetPresentationViewModel()

    init(
        presented: Binding<Bool>,
        style: [Detent],
        options: Binding<DetentPresentationOption>,
        @ViewBuilder content: @escaping () -> SwiftUIContent
    ) {
        _presented = presented
        self.content = content
        self.style = style
        self._options = options
    }

    func body(content: Content) -> some View {
        content
            .introspect(.viewController, on: .iOS(.v13...)) { vc in
                presentationViewModel.rootVC = vc
            }
            .onAppear { handle(isPresent: presented) }
            .onChange(of: presented) { isPresent in handle(isPresent: isPresent) }
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
                presentationViewModel.style = style
                let vcToPresent = getPresentationTarget()
                let content = self.content()
                let vc = hHostingController(rootView: content)

                let delegate = CenteredModalTransitioningDelegate()
                presentationViewModel.transitionDelegate = delegate
                vc.transitioningDelegate = delegate
                vc.modalPresentationStyle = .custom
                vc.isModalInPresentation = options.contains(.disableDismissOnScroll)

                vc.onDeinit = {
                    Task { @MainActor in
                        presented = false
                    }
                }

                if let presentingVC = vcToPresent {
                    presentingVC.present(vc, animated: true)
                } else {
                    assertionFailure("No valid view controller to present from.")
                }
            }
        } else {
            presentationViewModel.presentingVC?.dismiss(animated: true)
        }
    }

    private func getPresentationTarget() -> UIViewController? {
        if options.contains(.alwaysOpenOnTop) {
            let vc = UIApplication.shared.getTopViewController()
            return vc?.isBeingDismissed == true ? vc?.presentingViewController : vc
        } else {
            return presentationViewModel.rootVC ?? UIApplication.shared.getTopViewController()
        }
    }
}

@MainActor
class PageSheetPresentationViewModel: ObservableObject {
    weak var rootVC: UIViewController?
    var style: [Detent] = []
    weak var presentingVC: UIViewController?
    var transitionDelegate: UIViewControllerTransitioningDelegate?
}

final class CenteredModalTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    )
        -> UIPresentationController?
    {
        CenteredModalPresentationController(presentedViewController: presented, presenting: presenting)
    }
}

final class CenteredModalPresentationController: UIPresentationController {
    private let blurView: PassThroughEffectView?

    override init(
        presentedViewController: UIViewController,
        presenting presentingViewController: UIViewController?
    ) {
        if UITraitCollection.current.userInterfaceStyle == .dark {
            blurView = PassThroughEffectView(effect: UIBlurEffect(style: .light), isPageSheet: true)
        } else {
            blurView = PassThroughEffectView(effect: UIBlurEffect(style: .light), isPageSheet: true)
        }

        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        blurView?.alpha = 0

        // Dismiss on tap outside
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissOnTapOutside))
        blurView?.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissOnTapOutside() {
        presentedViewController.dismiss(animated: true, completion: nil)
    }

    override func presentationTransitionWillBegin() {
        guard let containerView, let blurView else { return }

        blurView.frame = containerView.bounds
        containerView.insertSubview(blurView, at: 0)

        presentedViewController.transitionCoordinator?
            .animate(alongsideTransition: { _ in
                blurView.alpha = 1
            })
    }

    override func dismissalTransitionWillBegin() {
        guard let blurView else { return }
        presentedViewController.transitionCoordinator?
            .animate(alongsideTransition: { _ in
                blurView.alpha = 0
            })
    }

    override var frameOfPresentedViewInContainerView: CGRect {
        guard let container = containerView else { return .zero }
        let width: CGFloat = min(container.bounds.width - 40, 400)
        let height: CGFloat = 500
        return CGRect(
            x: (container.bounds.width - width) / 2,
            y: (container.bounds.height - height) / 2,
            width: width,
            height: height
        )
    }

    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        blurView?.frame = containerView?.bounds ?? .zero
        presentedView?.frame = frameOfPresentedViewInContainerView
        presentedView?.layer.cornerRadius = 20
        presentedView?.layer.masksToBounds = true
    }
}

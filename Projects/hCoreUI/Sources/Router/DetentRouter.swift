import Foundation
import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect

extension View {
    public func detent<SwiftUIContent: View>(
        presented: Binding<Bool>,
        style: [Detent],
        options: Binding<DetentPresentationOption> = .constant([]),
        @ViewBuilder content: @escaping () -> SwiftUIContent
    ) -> some View {
        modifier(
            DetentSizeModifier(
                presented: presented,
                style: style,
                options: options,
                content: content
            )
        )
    }

    public func detent<Item, Content>(
        item: Binding<Item?>,
        style: [Detent],
        options: Binding<DetentPresentationOption> = .constant([]),
        @ViewBuilder content: @escaping (Item) -> Content
    ) -> some View where Item: Identifiable & Equatable, Content: View {
        return modifier(
            DetentSizeModifierModal(item: item, style: style, options: options, content: content)
        )
    }
}

private struct DetentSizeModifierModal<Item, SwiftUIContent>: ViewModifier
where SwiftUIContent: View, Item: Identifiable & Equatable {
    @Binding var item: Item?
    @State var itemToRenderFrom: Item?
    @State var present: Bool = false
    let style: [Detent]
    @Binding var options: DetentPresentationOption

    var content: (Item) -> SwiftUIContent
    func body(content: Content) -> some View {
        Group {
            content.detent(presented: $present, style: style, options: $options) {
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
    private let style: [Detent]
    @Binding var options: DetentPresentationOption
    @StateObject private var presentationViewModel = PresentationViewModel()
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
                let vcToPresent: UIViewController? = {
                    if options.contains(.alwaysOpenOnTop) {
                        let vc = UIApplication.shared.getTopViewController()
                        if vc?.isBeingDismissed == true {
                            return vc?.presentingViewController
                        }
                        return vc
                    }
                    return presentationViewModel.rootVC ?? UIApplication.shared.getTopViewController()

                }()
                let content = self.content()
                let vc = hHostingController(
                    rootView: content
                )
                let shouldUseBlur = style.contains(.height)
                let delegate = DetentedTransitioningDelegate(
                    detents: style,
                    options: shouldUseBlur ? [PresentationOptions.useBlur] : [],
                    wantsGrabber: options.contains(.withoutGrabber) ? false : true,
                    viewController: vc
                )
                if options.contains(.disableDismissOnScroll) {
                    vc.isModalInPresentation = true
                } else {
                    vc.isModalInPresentation = false
                }
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
}

class PresentationViewModel: ObservableObject {
    weak var rootVC: UIViewController?
    weak var presentingVC: UIViewController?
}

@MainActor
public class hHostingController<Content: View>: UIHostingController<Content>, Sendable {
    var onViewWillLayoutSubviews: () -> Void = {}
    var onViewDidLayoutSubviews: () -> Void = {}
    var onViewWillAppear: () -> Void = {}
    var onViewWillDisappear: () -> Void = {}
    private let key = UUID().uuidString
    var onDeinit: @Sendable () -> Void = {}
    private let contentName: String?
    public init(rootView: Content, contentName: String? = nil) {
        self.contentName = contentName
        super.init(rootView: rootView)
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        onViewDidLayoutSubviews()
    }

    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        onViewWillLayoutSubviews()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let name = self.debugDescription.getViewName() {
            logStartView(key, name)
        }
        onViewWillAppear()
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.debugDescription.getViewName() != nil {
            logStopView(key)
        }
        onViewWillDisappear()
    }
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion: completion)
    }

    deinit {
        self.onDeinit()
    }

    @objc func onCloseButton() {
        self.dismiss(animated: true)
    }

    public override var debugDescription: String {
        return contentName ?? ""
    }
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

    nonisolated public init(rawValue: UInt) {
        self.rawValue = rawValue
    }

}

extension String {
    fileprivate func getViewName() -> String? {
        if self.lowercased().contains("AnyView".lowercased()) || self.isEmpty {
            return nil
        }
        return self
    }
}

@MainActor public var logStartView: ((_ key: String, _ name: String) -> Void) = { _, _ in }
@MainActor public var logStopView: ((_ key: String) -> Void) = { _ in }

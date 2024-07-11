import Foundation
import Presentation
import SwiftUI

extension View {
    public func detent<SwiftUIContent: View>(
        presented: Binding<Bool>,
        style: DetentPresentationStyle,
        options: Binding<DetentPresentationOption> = .constant([]),
        tracking: TrackingViewNameProtocol? = nil,
        @ViewBuilder content: @escaping () -> SwiftUIContent
    ) -> some View {
        modifier(
            DetentSizeModifier(
                presented: presented,
                style: style,
                options: options,
                tracking: tracking,
                content: content
            )
        )
    }

    public func detent<Item, Content>(
        item: Binding<Item?>,
        style: DetentPresentationStyle,
        options: Binding<DetentPresentationOption> = .constant([]),
        tracking: TrackingViewNameProtocol? = nil,
        @ViewBuilder content: @escaping (Item) -> Content
    ) -> some View where Item: Identifiable & Equatable, Content: View {
        return modifier(
            DetentSizeModifierModal(item: item, style: style, options: options, tracking: tracking, content: content)
        )
    }
}

private struct DetentSizeModifierModal<Item, SwiftUIContent>: ViewModifier
where SwiftUIContent: View, Item: Identifiable & Equatable {
    @Binding var item: Item?
    @State var itemToRenderFrom: Item?
    @State var present: Bool = false
    let style: DetentPresentationStyle
    @Binding var options: DetentPresentationOption
    let tracking: TrackingViewNameProtocol?

    var content: (Item) -> SwiftUIContent
    func body(content: Content) -> some View {
        Group {
            content.detent(presented: $present, style: style, options: $options, tracking: tracking) {
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
    private let style: DetentPresentationStyle
    @Binding var options: DetentPresentationOption
    @StateObject private var presentationViewModel = PresentationViewModel()
    let tracking: TrackingViewNameProtocol?
    init(
        presented: Binding<Bool>,
        style: DetentPresentationStyle,
        options: Binding<DetentPresentationOption>,
        tracking: TrackingViewNameProtocol? = nil,
        @ViewBuilder content: @escaping () -> SwiftUIContent
    ) {
        _presented = presented
        self.content = content
        self.style = style
        self.tracking = tracking
        self._options = options
    }

    @ViewBuilder
    func body(content: Content) -> some View {
        content
            .introspectViewController(customize: { vc in
                presentationViewModel.rootVC = vc
            })
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
                    rootView: content,
                    contentName: tracking?.nameForTracking ?? "\(Content.self)"
                )
                let delegate = DetentedTransitioningDelegate(
                    detents: style.asDetent(),
                    options: [.blurredBackground],
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
                    presented = false
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

public class hHostingController<Content: View>: UIHostingController<Content> {
    var onViewWillLayoutSubviews: () -> Void = {}
    var onViewDidLayoutSubviews: () -> Void = {}
    var onViewWillAppear: () -> Void = {}
    var onViewWillDisappear: () -> Void = {}
    private let key = UUID().uuidString
    var onDeinit: () -> Void = {}
    private let contentName: String
    public init(rootView: Content, contentName: String) {
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
        if let name = self.debugDescription.getViewName() {
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
        onDeinit()
    }

    @objc func onCloseButton() {
        self.dismiss(animated: true)
    }

    public override var debugDescription: String {
        return contentName
    }
}

public struct DetentPresentationStyle: OptionSet {
    public let rawValue: UInt
    public static let medium = DetentPresentationStyle(rawValue: 1 << 0)
    public static let large = DetentPresentationStyle(rawValue: 1 << 1)
    public static let height = DetentPresentationStyle(rawValue: 1 << 2)

    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }

    func asDetent() -> [PresentationStyle.Detent] {
        var detents = [PresentationStyle.Detent]()
        if self.contains(.medium) {
            detents.append(.medium)
        }
        if self.contains(.large) {
            detents.append(.large)
        }
        if self.contains(.height) {
            detents.append(.scrollViewContentSize)
        }
        return detents
    }
}

extension UIViewController {
    var className: String {
        String(describing: Self.self)
    }
}

public struct DetentPresentationOption: OptionSet {
    public let rawValue: UInt
    public static let alwaysOpenOnTop = DetentPresentationOption(rawValue: 1 << 0)
    public static let withoutGrabber = DetentPresentationOption(rawValue: 1 << 2)
    public static let disableDismissOnScroll = DetentPresentationOption(rawValue: 1 << 3)

    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }

}

extension String {
    fileprivate func getViewName() -> String? {
        let removedModifiedContent = self.replacingOccurrences(of: "ModifiedContent<", with: "")
        guard let firstElement = removedModifiedContent.split(separator: ",").first else { return nil }
        let nameToLog = String(firstElement)
        if !nameToLog.shouldBeLoggedAsView {
            return nil
        }
        let elements: [String] = {
            if #available(iOS 16.0, *) {
                return nameToLog.split(separator: "SizeModifier<").map({ String($0) })
            } else {
                return nameToLog.components(separatedBy: "SizeModifier<")
            }
        }()
        if elements.count > 1, let lastElement = elements.last {
            return String(lastElement).replacingOccurrences(of: "Optional<", with: "")
                .replacingOccurrences(of: ">", with: "")
        } else {
            let elements = nameToLog.split(separator: ":")
            if elements.count > 1, let firstElement = elements.first {
                return String(firstElement).replacingOccurrences(of: "<", with: "")
            }
            return nameToLog
        }
    }
    fileprivate var shouldBeLoggedAsView: Bool {

        let array = [
            String(describing: hNavigationController.self),
            String(describing: hNavigationControllerWithLargerNavBar.self),
            "EmbededInNavigation",
            "PUPickerRemoteViewController",
            "CAMImagePickerCameraViewController",
            "CAMViewfinderViewController",
            "UIDocumentBrowserViewController",
            "Navigation",

        ]
        for element in array {
            if self.contains(element) {
                return false
            }
        }
        return true
    }
}

public var logStartView: ((_ key: String, _ name: String) -> Void) = { _, _ in }
public var logStopView: ((_ key: String) -> Void) = { _ in }

import Foundation
import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect

extension View {
    public func modally<SwiftUIContent: View>(
        presented: Binding<Bool>,
        options: Binding<DetentPresentationOption> = .constant([]),
        tracking: TrackingViewNameProtocol? = nil,
        @ViewBuilder content: @escaping () -> SwiftUIContent
    ) -> some View {
        modifier(ModallySizeModifier(presented: presented, options: options, tracking: tracking, content: content))
    }

    public func modally<Item, Content>(
        item: Binding<Item?>,
        options: Binding<DetentPresentationOption> = .constant([]),
        tracking: TrackingViewNameProtocol? = nil,
        @ViewBuilder content: @escaping (Item) -> Content
    ) -> some View where Item: Identifiable & Equatable, Content: View {
        modifier(ModallySizeItemModifier(item: item, options: options, tracking: tracking, content: content))
    }
}

private struct ModallySizeItemModifier<Item, SwiftUIContent>: ViewModifier
where SwiftUIContent: View, Item: Identifiable & Equatable {
    @Binding var item: Item?
    @State var itemToRenderFrom: Item?
    @State var present: Bool = false
    @Binding var options: DetentPresentationOption
    let tracking: TrackingViewNameProtocol?
    var content: (Item) -> SwiftUIContent
    func body(content: Content) -> some View {
        Group {
            content.modally(presented: $present, options: $options, tracking: tracking) {
                if let item = itemToRenderFrom {
                    self.content(item)
                }
            }
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

private struct ModallySizeModifier<SwiftUIContent>: ViewModifier where SwiftUIContent: View {
    @Binding var presented: Bool
    let content: () -> SwiftUIContent
    @Binding var options: DetentPresentationOption
    let tracking: TrackingViewNameProtocol?
    @StateObject private var presentationViewModel = PresentationViewModel()
    init(
        presented: Binding<Bool>,
        options: Binding<DetentPresentationOption>,
        tracking: TrackingViewNameProtocol?,
        @ViewBuilder content: @escaping () -> SwiftUIContent
    ) {
        _presented = presented
        self.content = content
        self.tracking = tracking
        _options = options
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
                    rootView: content,
                    contentName: tracking?.nameForTracking ?? "\(Content.self)"
                )
                vc.modalPresentationStyle = .overFullScreen
                vc.transitioningDelegate = .none
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

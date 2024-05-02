import Foundation
import SwiftUI

extension View {
    public func modally<SwiftUIContent: View>(
        presented: Binding<Bool>,
        options: Binding<DetentPresentationOption> = .constant([]),
        @ViewBuilder content: @escaping () -> SwiftUIContent
    ) -> some View {
        modifier(ModallySizeModifier(presented: presented, options: options, content: content))
    }

    public func modally<Item, Content>(
        item: Binding<Item?>,
        options: Binding<DetentPresentationOption> = .constant([]),
        @ViewBuilder content: @escaping (Item) -> Content
    ) -> some View where Item: Identifiable & Equatable, Content: View {
        return modifier(ModallySizeItemModifier(item: item, options: options, content: content))
    }
}

private struct ModallySizeItemModifier<Item, SwiftUIContent>: ViewModifier
where SwiftUIContent: View, Item: Identifiable & Equatable {
    @Binding var item: Item?
    @State var itemToRenderFrom: Item?
    @State var present: Bool = false
    @Binding var options: DetentPresentationOption
    var content: (Item) -> SwiftUIContent
    func body(content: Content) -> some View {
        Group {
            content.modally(presented: $present, options: $options) {
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
        .onChange(of: present) { newValue in
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
    @StateObject private var presentationViewModel = PresentationViewModel()
    init(
        presented: Binding<Bool>,
        options: Binding<DetentPresentationOption>,
        @ViewBuilder content: @escaping () -> SwiftUIContent
    ) {
        _presented = presented
        self.content = content
        self._options = options
    }

    @ViewBuilder
    func body(content: Content) -> some View {
        content
            .introspectViewController(customize: { vc in
                presentationViewModel.rootVC = vc
            })
            .onChange(of: presented) { newValue in
                if newValue {
                    var withDelay = false
                    if options.contains(.replaceCurrent) {
                        if let vc = presentationViewModel.rootVC?.presentingViewController {
                            presentationViewModel.rootVC?.dismiss(animated: true)
                            presentationViewModel.rootVC = vc
                            withDelay = true
                        }
                    } else if !options.contains(.alwaysOpenOnTop) {
                        if let presentedVC = presentationViewModel.rootVC?.presentedViewController {
                            presentedVC.dismiss(animated: true)
                            withDelay = true
                        }
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + (withDelay ? 0.8 : 0)) {
                        let vcToPresent: UIViewController? = {
                            if options.contains(.alwaysOpenOnTop) {
                                return UIApplication.shared.getTopViewController()
                            }
                            return presentationViewModel.rootVC ?? UIApplication.shared.getTopViewController()

                        }()
                        let content = self.content()
                        let vc = hHostingController(rootView: content, contentName: "\(Content.self)")
                        vc.modalPresentationStyle = .overFullScreen
                        vc.transitioningDelegate = .none
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
}

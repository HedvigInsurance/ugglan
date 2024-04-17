import Foundation
import Presentation
import SwiftUI

extension View {
    public func detent<SwiftUIContent: View>(
        presented: Binding<Bool>,
        style: DetentPresentationStyle,
        @ViewBuilder content: @escaping () -> SwiftUIContent
    ) -> some View {
        modifier(DetentSizeModifier(presented: presented, style: style, content: content))
    }

    public func detent<Item, Content>(
        item: Binding<Item?>,
        style: DetentPresentationStyle,
        @ViewBuilder content: @escaping (Item) -> Content
    ) -> some View where Item: Identifiable & Equatable, Content: View {
        return modifier(DetentSizeModifierModal(item: item, style: style, content: content))
    }
}

private struct DetentSizeModifierModal<Item, SwiftUIContent>: ViewModifier
where SwiftUIContent: View, Item: Identifiable & Equatable {
    @Binding var item: Item?
    @State var itemToRenderFrom: Item?
    @State var present: Bool = false
    let style: DetentPresentationStyle
    var content: (Item) -> SwiftUIContent
    func body(content: Content) -> some View {
        Group {
            content.detent(presented: $present, style: style) {
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

private struct DetentSizeModifier<SwiftUIContent>: ViewModifier where SwiftUIContent: View {

    @Binding var presented: Bool
    let content: () -> SwiftUIContent
    private let style: DetentPresentationStyle
    @StateObject private var presentationViewModel = PresentationViewModel()
    init(
        presented: Binding<Bool>,
        style: DetentPresentationStyle,
        @ViewBuilder content: @escaping () -> SwiftUIContent
    ) {
        _presented = presented
        self.content = content
        self.style = style
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
                    if let presentedVC = presentationViewModel.rootVC?.presentedViewController {
                        presentedVC.dismiss(animated: true)
                        withDelay = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + (withDelay ? 0.8 : 0)) {
                        let topVC = presentationViewModel.rootVC ?? UIApplication.shared.getTopViewController()
                        let content = self.content()
                        let vc = hHostingController(rootView: content)
                        let delegate = DetentedTransitioningDelegate(
                            detents: style.asDetent(),
                            options: [.blurredBackground],
                            wantsGrabber: true,
                            viewController: vc
                        )
                        vc.transitioningDelegate = delegate
                        vc.modalPresentationStyle = .custom

                        vc.onDeinit = {
                            presented = false
                        }
                        presentationViewModel.presentingVC = vc
                        topVC?.present(vc, animated: true)
                    }
                } else {
                    presentationViewModel.presentingVC?.dismiss(animated: true)
                }
            }
    }
}

private class PresentationViewModel: ObservableObject {
    weak var rootVC: UIViewController?
    weak var presentingVC: UIViewController?

}

class hHostingController<Content: View>: UIHostingController<Content> {
    var onDeinit: () -> Void = {}

    public override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion: completion)
    }

    deinit {
        onDeinit()
    }
}

extension View {
    public func withClose(for presented: Binding<Bool>) -> some View {
        modifier(CloseButtonModifier(isPresented: presented))
    }
}

private struct CloseButtonModifier: ViewModifier {
    @Binding var isPresented: Bool
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(
                    placement: .topBarTrailing

                ) {
                    dismissButton
                }
            }
    }

    private var dismissButton: some View {
        hButton.MediumButton(type: .ghost) {
            isPresented = false
        } content: {
            HCoreUIAsset.close.swiftUIImage
        }
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

import Combine
import Foundation
import SwiftUI

struct ViewIntrospector<ViewType: UIView>: UIViewRepresentable {
    var foundView: (_ view: ViewType) -> Void

    class Coordinator {
        var view: ViewType?
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context _: Context) -> some UIView {
        UIView()
    }

    func findView(from: UIView) -> ViewType? {
        if let view = from as? ViewType {
            return view
        } else if let view = from.subviews
            .compactMap({ view in
                findView(from: view)
            })
            .first
        {
            return view
        }

        return nil
    }

    func traverseUp(from view: UIView, levels: Int = 0) -> ViewType? {
        if levels > 5 {
            return nil
        }

        guard let superview = view.superview else {
            return nil
        }

        if let view = findView(from: superview) {
            return view
        }

        return traverseUp(from: superview, levels: levels + 1)
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
        guard context.coordinator.view == nil else {
            return
        }

        DispatchQueue.main.async {
            let view = traverseUp(from: uiView)
            context.coordinator.view = view

            if let view = view {
                foundView(view)
            }
        }
    }
}

extension View {
    public func findScrollView(_ foundScrollView: @escaping (_ scrollView: UIScrollView) -> Void) -> some View {
        background(ViewIntrospector<UIScrollView>(foundView: foundScrollView))
    }
}

public struct ForceScrollViewIndicatorInset: ViewModifier {
    @State var scrollView: UIScrollView?
    @State var defaultContentOffset: CGFloat = 0
    @State var addedContentOffset: CGFloat = 0

    var insetBottom: CGFloat

    public init(
        insetBottom: CGFloat
    ) {
        self.insetBottom = insetBottom
    }

    var contentOffsetPublisher: AnyPublisher<CGPoint, Never> {
        if let scrollView = scrollView {
            return scrollView.publisher(for: \.contentOffset).eraseToAnyPublisher()
        }

        return Just(CGPoint.zero).eraseToAnyPublisher()
    }

    var boundsYPublisher: AnyPublisher<CGRect, Never> {
        if let scrollView = scrollView, scrollView.superview != nil {
            return scrollView.publisher(for: \.bounds).eraseToAnyPublisher()
        }

        return Just(CGRect.zero).eraseToAnyPublisher()
    }

    public func body(content: Content) -> some View {
        content.findScrollView { scrollView in
            self.scrollView = scrollView
            scrollView.viewController?.setContentScrollView(scrollView, for: .top)
        }
        .onReceive(contentOffsetPublisher) { _ in
            scrollView?.verticalScrollIndicatorInsets.bottom =
                insetBottom + (scrollView?.adjustedContentInset.bottom ?? 0)
        }
        .onReceive(boundsYPublisher) { value in
            if defaultContentOffset == 0 {
                defaultContentOffset = value.origin.y
            }
            if defaultContentOffset != 0 {
                addedContentOffset = value.origin.y - defaultContentOffset
            }
        }
    }
}

public struct ForceScrollViewTopInset: ViewModifier {
    @State var scrollView: UIScrollView?
    @State var defaultContentOffset: CGFloat = 0
    @Binding var addedContentOffset: CGFloat
    let shouldFollow: Bool

    public init(addedContentOffset: Binding<CGFloat>, shouldFollow: Bool) {
        _addedContentOffset = addedContentOffset
        self.shouldFollow = shouldFollow
    }

    var boundsYPublisher: AnyPublisher<CGRect, Never> {
        if let scrollView = scrollView, scrollView.superview != nil {
            return scrollView.publisher(for: \.bounds).eraseToAnyPublisher()
        }

        return Just(CGRect.zero).eraseToAnyPublisher()
    }

    public func body(content: Content) -> some View {
        content.findScrollView { scrollView in
            self.scrollView = scrollView
            scrollView.viewController?.setContentScrollView(scrollView)
        }
        .onReceive(boundsYPublisher) { value in
            if !shouldFollow {
                return
            }
            if defaultContentOffset == 0 {
                defaultContentOffset = value.origin.y
            }
            if defaultContentOffset != 0 {
                addedContentOffset = value.origin.y - defaultContentOffset
            }
        }
    }
}

public struct ContentOffsetModifier<Modifier: ViewModifier>: ViewModifier {
    public init(
        modifier: @escaping (UIScrollView, CGPoint) -> Modifier
    ) {
        self.modifier = modifier
    }

    @State var scrollView: UIScrollView?
    @State var contentOffset: CGPoint = .zero

    var modifier: (_ scrollView: UIScrollView, _ contentOffset: CGPoint) -> Modifier

    var contentOffsetPublisher: AnyPublisher<CGPoint, Never> {
        if let scrollView = scrollView {
            return scrollView.publisher(for: \.contentOffset).eraseToAnyPublisher()
        }

        return Just(CGPoint.zero).eraseToAnyPublisher()
    }

    public func body(content: Content) -> some View {
        content.findScrollView { scrollView in
            self.scrollView = scrollView
        }
        .modifier(modifier(scrollView ?? UIScrollView(), contentOffset))
        .onReceive(contentOffsetPublisher) { contentOffset in
            self.contentOffset = contentOffset
        }
    }
}

extension UIView {
    /// Returns the first found view controller if any, walking up the responder chain.
    public var viewController: UIViewController? {
        if let vc = next as? UIViewController {
            return vc
        } else {
            return superview?.viewController
        }
    }
}

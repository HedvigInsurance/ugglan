import Combine
import Foundation
import SwiftUI
import UIKit

struct ViewIntrospector<ViewType: UIView>: UIViewRepresentable {
    var foundView: (_ view: ViewType) -> Void

    class Coordinator {
        var view: ViewType? = nil
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> some UIView {
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
    public func introspectScrollView(_ foundScrollView: @escaping (_ scrollView: UIScrollView) -> Void) -> some View {
        self.background(ViewIntrospector<UIScrollView>(foundView: foundScrollView))
    }

    public func introspectTextField(_ foundTextField: @escaping (_ textField: UITextField) -> Void) -> some View {
        self.background(ViewIntrospector<UITextField>(foundView: foundTextField))
    }
}

public struct ForceScrollViewIndicatorInset: ViewModifier {
    @State var scrollView: UIScrollView?
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

    public func body(content: Content) -> some View {
        content.introspectScrollView { scrollView in
            self.scrollView = scrollView

            if #available(iOS 15.0, *) {
                scrollView.viewController?.setContentScrollView(scrollView)
            }
        }
        .onReceive(contentOffsetPublisher) { _ in
            scrollView?.verticalScrollIndicatorInsets.bottom =
                insetBottom + (scrollView?.adjustedContentInset.bottom ?? 0)
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
        content.introspectScrollView { scrollView in
            self.scrollView = scrollView
        }
        .modifier(modifier(scrollView ?? UIScrollView(), contentOffset))
        .onReceive(contentOffsetPublisher) { contentOffset in
            self.contentOffset = contentOffset
        }
    }
}

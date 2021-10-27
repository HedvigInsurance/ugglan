import Combine
import Foundation
import SwiftUI
import UIKit

struct ScrollViewIntrospector: UIViewRepresentable {
    var foundScrollView: (_ scrollView: UIScrollView) -> Void

    func makeUIView(context: Context) -> some UIView {
        UIView()
    }

    func findScrollView(from: UIView) {
        if let scrollView = from.subviews
            .compactMap({ view in
                view as? UIScrollView
            })
            .first
        {
            foundScrollView(scrollView)
        } else if let parent = from.parent {
            findScrollView(from: parent)
        }
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
        DispatchQueue.main.async {
            findScrollView(from: uiView)
        }
    }
}

extension View {
    public func introspectScrollView(_ foundScrollView: @escaping (_ scrollView: UIScrollView) -> Void) -> some View {
        self.background(ScrollViewIntrospector(foundScrollView: foundScrollView))
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

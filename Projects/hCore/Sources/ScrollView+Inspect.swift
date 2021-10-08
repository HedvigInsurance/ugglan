//
//  ScrollView+Inspect.swift
//  ScrollView+Inspect
//
//  Created by Sam Pettersson on 2021-10-08.
//  Copyright © 2021 Hedvig AB. All rights reserved.
//

import Foundation
import UIKit
import Combine
import SwiftUI

struct ScrollViewIntrospector: UIViewRepresentable {
    var foundScrollView: (_ scrollView: UIScrollView) -> Void
    
    func makeUIView(context: Context) -> some UIView {
        UIView()
    }
    
    func findScrollView(from: UIView) {
        if let scrollView = from.subviews.compactMap({ view in
            view as? UIScrollView
        }).first {
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
    func introspectScrollView(_ foundScrollView: @escaping (_ scrollView: UIScrollView) -> Void) -> some View {
        self.background(ScrollViewIntrospector(foundScrollView: foundScrollView))
    }
}

public struct ForceScrollViewIndicatorInset: ViewModifier {
    @State var scrollView: UIScrollView?
    var insetBottom: CGFloat
    
    public init(insetBottom: CGFloat) {
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
        }.onReceive(contentOffsetPublisher) { _ in
            scrollView?.verticalScrollIndicatorInsets.bottom = insetBottom + (scrollView?.adjustedContentInset.bottom ?? 0)
        }
    }
}

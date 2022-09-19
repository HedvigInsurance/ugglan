import Flow
import Form
import Foundation
import Presentation
import SwiftUI
import UIKit
import hCore
import hCoreUI

struct BottomAttachedSignButton: Presentable {
    func materialize() -> (UIView, Disposable) {
        return (HostingView(rootView: self, edgesIgnoringSafeArea: .none), DisposeBag())
    }
}

struct BottomAttachedSignButtonOffsetModifier: ViewModifier {
    var scrollView: UIScrollView
    var contentOffset: CGPoint

    func body(content: Content) -> some View {
        content
            .transformEffect(
                .init(
                    translationX: 0,
                    y: max(150 - scrollView.contentOffset.y, 0)
                )
            )
    }
}

extension BottomAttachedSignButton: View {
    var body: some View {
        hFormBottomAttachedBackground {
            SignSection().padding(.bottom, 15)
        }
        .modifier(
            ContentOffsetModifier { scrollView, contentOffset in
                BottomAttachedSignButtonOffsetModifier(scrollView: scrollView, contentOffset: contentOffset)
            }
        )
    }
}

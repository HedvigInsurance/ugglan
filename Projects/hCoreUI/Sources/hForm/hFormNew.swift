import Combine
import Flow
import Foundation
import SwiftUI
import UIKit
import hCore

private struct EnvironmentHFormBottomAttachedView: EnvironmentKey {
    static let defaultValue: AnyView? = nil
}

//extension EnvironmentValues {
//    public var hFormBottomAttachedView: AnyView? {
//        get { self[EnvironmentHFormBottomAttachedView.self] }
//        set { self[EnvironmentHFormBottomAttachedView.self] = newValue }
//    }
//}
//
//extension View {
//    public func hFormAttachToBottom<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
//        self.environment(\.hFormBottomAttachedView, AnyView(content()))
//    }
//}

struct BackgroundViewNew: UIViewRepresentable {
    func updateUIView(_ uiView: UIViewType, context: Context) {
        uiView.backgroundColor = .brandNew(.primaryBackground())
    }

    func makeUIView(context: Context) -> some UIView {
        UIView()
    }
}

public struct hFormNew<Content: View>: View {
    @ObservedObject var gradientState = GradientState.shared
    let gradientType: GradientType

    @State var shouldAnimateGradient = true

    @State var bottomAttachedViewHeight: CGFloat = 0
    @Environment(\.hFormBottomAttachedView) var bottomAttachedView
    var content: Content

    public init(
        gradientType: GradientType = .none,
        @ViewBuilder _ builder: () -> Content
    ) {
        self.content = builder()
        self.gradientType = gradientType
        gradientState.gradientType = gradientType
    }

    public var body: some View {
        ZStack {
            if gradientType != .none {
                hGradient(
                    oldGradientType: $gradientState.oldGradientType,
                    newGradientType: $gradientState.gradientType,
                    animate: $shouldAnimateGradient
                )
                .onDisappear {
                    shouldAnimateGradient = gradientState.gradientTypeBeforeNone != gradientType
                }
                .onAppear {
                    if gradientState.gradientTypeBeforeNone == gradientType {
                        gradientState.gradientTypeBeforeNone = nil
                    }
                }
            } else {
                BackgroundViewNew().edgesIgnoringSafeArea(.all)
            }
            ScrollView {
                VStack {
                    content
                }
                .frame(maxWidth: .infinity)
                .tint(hTintColor.lavenderOne)
                Color.clear
                    .frame(height: bottomAttachedViewHeight)
            }
            .modifier(ForceScrollViewIndicatorInset(insetBottom: bottomAttachedViewHeight))
            .introspectScrollView { scrollView in
                if #available(iOS 15, *) {
                    scrollView.viewController?.setContentScrollView(scrollView)
                }
            }
            bottomAttachedView
                .background(
                    GeometryReader { geo in
                        Color.clear.onReceive(Just(geo.size.height)) { height in
                            self.bottomAttachedViewHeight = height
                        }
                    }
                )
                .frame(maxHeight: .infinity, alignment: .bottom)
        }
    }
}

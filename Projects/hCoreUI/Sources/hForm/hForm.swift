import Combine
import Flow
import Foundation
import SwiftUI
import UIKit
import hCore

private struct EnvironmentHFormBottomAttachedView: EnvironmentKey {
    static let defaultValue: AnyView? = nil
}

extension EnvironmentValues {
    public var hFormBottomAttachedView: AnyView? {
        get { self[EnvironmentHFormBottomAttachedView.self] }
        set { self[EnvironmentHFormBottomAttachedView.self] = newValue }
    }
}

extension View {
    public func hFormAttachToBottom<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        self.environment(\.hFormBottomAttachedView, AnyView(content()))
    }
}

private struct EnvironmentHFormTitle: EnvironmentKey {
    static let defaultValue: String? = nil
}

extension EnvironmentValues {
    public var hFormTitle: String? {
        get { self[EnvironmentHFormTitle.self] }
        set { self[EnvironmentHFormTitle.self] = newValue }
    }
}

extension View {
    public func hFormTitle(_ title: String) -> some View {
        self.environment(\.hFormTitle, title)
    }
}

struct BackgroundView: UIViewRepresentable {
    @Environment(\.hUseNewStyle) var hUseNewStyle

    func updateUIView(_ uiView: UIViewType, context: Context) {
        if hUseNewStyle {
            uiView.backgroundColor = .brandNew(.primaryBackground())
        } else {
            uiView.backgroundColor = .brand(.primaryBackground())
        }
    }

    func makeUIView(context: Context) -> some UIView {
        UIView()
    }
}

public struct hForm<Content: View>: View {
    @ObservedObject var gradientState = GradientState.shared
    let gradientType: GradientType

    @State var shouldAnimateGradient = true

    @State var bottomAttachedViewHeight: CGFloat = 0
    @Environment(\.hFormBottomAttachedView) var bottomAttachedView
    @Environment(\.hUseNewStyle) var hUseNewStyle
    @Environment(\.hFormTitle) var hFormTitle
    var content: Content

    public init(
        gradientType: GradientType = .none,
        @ViewBuilder _ builder: () -> Content
    ) {
        self.content = builder()
        self.gradientType = gradientType
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
                BackgroundView().edgesIgnoringSafeArea(.all)
            }
            ScrollView {
                VStack {
                    if let hFormTitle, hUseNewStyle {
                        Text(hFormTitle)
                    }
                    content
                }
                .frame(maxWidth: .infinity)
                .tint(hForm<Content>.returnTintColor(useNewStyle: hUseNewStyle))
                Color.clear
                    .frame(height: bottomAttachedViewHeight)
            }
            .modifier(ForceScrollViewIndicatorInset(insetBottom: bottomAttachedViewHeight))
            .findScrollView { scrollView in
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
        .onAppear {
            self.gradientState.gradientType = gradientType
        }

    }

    @hColorBuilder
    static func returnTintColor(useNewStyle: Bool) -> some hColor {
        if useNewStyle {
            hGreenColorNew.green100
        } else {
            hTintColor.lavenderOne
        }
    }
}

private struct EnvironmentHUseNewStyle: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    public var hUseNewStyle: Bool {
        get { self[EnvironmentHUseNewStyle.self] }
        set { self[EnvironmentHUseNewStyle.self] = newValue }
    }
}

extension View {
    public var hUseNewStyle: some View {
        self.environment(\.hUseNewStyle, true)
    }
}

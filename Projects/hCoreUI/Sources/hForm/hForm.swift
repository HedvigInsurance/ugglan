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

private struct EnvironmentHDisableScroll: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    public var hDisableScroll: Bool {
        get { self[EnvironmentHDisableScroll.self] }
        set { self[EnvironmentHDisableScroll.self] = newValue }
    }
}

extension View {
    public var hDisableScroll: some View {
        self.environment(\.hDisableScroll, true)
    }
}

private struct EnvironmentHFormTitle: EnvironmentKey {
    static let defaultValue: (type: HFormTitleSpacingType, fontSize: HFontTextStyle, title: String)? = nil
}

public enum HFormTitleSpacingType {
    case standard
    case small

    var topMargin: CGFloat {
        switch self {
        case .standard:
            return 56
        case .small:
            return 16
        }
    }

    var bottomMargin: CGFloat {
        switch self {
        case .standard:
            return 64
        case .small:
            return 0
        }
    }
}

extension EnvironmentValues {
    public var hFormTitle: (HFormTitleSpacingType, HFontTextStyle, String)? {
        get { self[EnvironmentHFormTitle.self] }
        set { self[EnvironmentHFormTitle.self] = newValue }
    }
}

extension View {
    public func hFormTitle(_ type: HFormTitleSpacingType, _ fontSize: HFontTextStyle, _ title: String) -> some View {
        self.environment(\.hFormTitle, (type, fontSize, title))
    }
}

struct BackgroundView: UIViewRepresentable {

    func updateUIView(_ uiView: UIViewType, context: Context) {
        uiView.backgroundColor = .brandNew(.primaryBackground())
    }

    func makeUIView(context: Context) -> some UIView {
        UIView()
    }
}

struct BackgroundBlurView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        DispatchQueue.main.async {
            view.superview?.superview?.backgroundColor = UIColor.white.withAlphaComponent(0.4)
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

public struct hForm<Content: View>: View {
    @ObservedObject var gradientState = GradientState.shared
    let gradientType: GradientType

    @State var shouldAnimateGradient = true
    @State var bottomAttachedViewHeight: CGFloat = 0
    @State var scrollViewHeight: CGFloat = 0

    @Environment(\.hFormBottomAttachedView) var bottomAttachedView
    @Environment(\.hFormTitle) var hFormTitle
    @Environment(\.hDisableScroll) var hDisableScroll
    var content: Content

    public init(
        gradientType: GradientType = .none,
        @ViewBuilder _ builder: () -> Content
    ) {
        self.content = builder()
        self.gradientType = gradientType
    }

    public var body: some View {
        ZStack(alignment: .bottom) {
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
            getScrollView()
            BackgroundBlurView()
                .frame(
                    height: bottomAttachedViewHeight + (UIApplication.shared.safeArea?.bottom ?? 0),
                    alignment: .bottom
                )
                .offset(y: UIApplication.shared.safeArea?.bottom ?? 0)
                .ignoresSafeArea(.all)
            bottomAttachedView
                .background(
                    GeometryReader { geo in
                        Color.clear
                            .onReceive(Just(geo.size.height)) { height in
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

    func getScrollView() -> some View {
        ScrollView {
            VStack {
                if let hFormTitle {
                    hText(hFormTitle.2, style: hFormTitle.1)
                        .multilineTextAlignment(.center)
                        .padding(.top, hFormTitle.0.topMargin)
                        .padding(.bottom, hFormTitle.0.bottomMargin)
                        .padding([.leading, .trailing], 16)
                }
                content
            }
            .frame(maxWidth: .infinity)
            .tint(hForm<Content>.returnTintColor())
            Color.clear
                .frame(height: bottomAttachedViewHeight)
        }
        .modifier(ForceScrollViewIndicatorInset(insetBottom: bottomAttachedViewHeight))
        .findScrollView { scrollView in
            if #available(iOS 15, *) {
                scrollView.viewController?.setContentScrollView(scrollView)
            }
            if hDisableScroll {
                scrollView.bounces = false
            }
            scrollViewHeight =
                scrollView.frame.size.height - scrollView.contentInset.top - scrollView.contentInset.bottom
        }
    }

    @hColorBuilder
    static func returnTintColor() -> some hColor {
        hSignalColorNew.greenFill
    }
}

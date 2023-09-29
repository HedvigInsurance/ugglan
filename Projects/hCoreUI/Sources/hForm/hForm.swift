import Combine
import Flow
import Foundation
import SwiftUI
import UIKit
import hCore

private enum AnimationKeys {
    static let bottomAnimationKey = "bottomAnimationKey"
}

public struct hForm<Content: View>: View {
    @State var bottomAttachedViewHeight: CGFloat = 0
    @State var scrollViewHeight: CGFloat = 0
    @State var contentHeight: CGFloat = 0
    @State var titleHeight: CGFloat = 0
    @State var additionalSpaceFromTop: CGFloat = 0
    @State var shouldIgnoreTitleMargins = false
    @State var mergeBottomViewWithContent = false
    @State var scrollView: UIScrollView?
    @Environment(\.hFormBottomAttachedView) var bottomAttachedView
    @Environment(\.hFormTitle) var hFormTitle
    @Environment(\.hDisableScroll) var hDisableScroll
    @Environment(\.hFormContentPosition) var contentPosition
    @Environment(\.hFormMergeBottomWithContentIfNeeded) var mergeBottomWithContentIfNeeded
    var content: Content
    @Namespace private var animation

    public init(
        @ViewBuilder _ builder: () -> Content
    ) {
        self.content = builder()
    }

    public var body: some View {
        ZStack(alignment: .bottom) {
            if hDisableScroll {
                getScrollView().clipped()
            } else {
                getScrollView()
            }
            if mergeBottomViewWithContent {
                bottomAttachedView
                    .background(
                        GeometryReader { geo in
                            Color.clear
                                .onReceive(Just(geo.size.height)) { height in
                                    if bottomAttachedViewHeight == 0 {
                                        self.bottomAttachedViewHeight = height
                                    } else {
                                        withAnimation {
                                            self.bottomAttachedViewHeight = height
                                            recalculateHeight()
                                        }
                                    }
                                }
                        }
                    )
                    .frame(maxHeight: .infinity, alignment: .bottom)
                    .opacity(0)
            } else {
                BackgroundBlurView()
                    .frame(
                        height: bottomAttachedViewHeight + (UIApplication.shared.safeArea?.bottom ?? 0),
                        alignment: .bottom
                    )
                    .offset(y: UIApplication.shared.safeArea?.bottom ?? 0)
                    .ignoresSafeArea(.all)
                bottomAttachedView
                    .matchedGeometryEffect(id: AnimationKeys.bottomAnimationKey, in: animation)
                    .background(
                        GeometryReader { geo in
                            Color.clear
                                .onReceive(Just(geo.size.height)) { height in
                                    if bottomAttachedViewHeight == 0 {
                                        self.bottomAttachedViewHeight = height
                                    } else {
                                        withAnimation {
                                            self.bottomAttachedViewHeight = height
                                            recalculateHeight()
                                        }
                                    }
                                }
                        }
                    )
                    .frame(maxHeight: .infinity, alignment: .bottom)
            }
        }
        .background(
            BackgroundView().edgesIgnoringSafeArea(.all)
        )
    }

    func getScrollView() -> some View {
        ScrollView {
            Rectangle().fill(Color.clear).frame(height: additionalSpaceFromTop)
            VStack(spacing: 8) {
                VStack(spacing: 0) {

                    if let hFormTitle {
                        hText(hFormTitle.2, style: hFormTitle.1)
                            .multilineTextAlignment(.center)
                            .padding(.top, shouldIgnoreTitleMargins ? 0 : hFormTitle.0.topMargin)
                            .padding(.bottom, shouldIgnoreTitleMargins ? 0 : hFormTitle.0.bottomMargin)
                            .padding([.leading, .trailing], 16)
                    }
                    content.padding(.vertical, -8)
                }
                .background(
                    GeometryReader { proxy in
                        Color.clear
                            .onAppear {
                                withAnimation {
                                    contentHeight = proxy.size.height
                                    recalculateHeight()
                                }
                            }
                            .onChange(of: proxy.size) { size in
                                withAnimation {
                                    contentHeight = size.height
                                    recalculateHeight()
                                }
                            }
                    }
                )
                if mergeBottomViewWithContent {
                    bottomAttachedView
                        .matchedGeometryEffect(id: AnimationKeys.bottomAnimationKey, in: animation)
                }
            }
            .frame(maxWidth: .infinity)
            .tint(hForm<Content>.returnTintColor())
            Color.clear
                .frame(height: mergeBottomWithContentIfNeeded ? 0 : bottomAttachedViewHeight)
        }
        .modifier(
            ForceScrollViewIndicatorInset(insetBottom: mergeBottomWithContentIfNeeded ? 0 : bottomAttachedViewHeight)
        )
        .findScrollView { scrollView in
            if mergeBottomWithContentIfNeeded {
                self.scrollView = scrollView
            }
            if #available(iOS 15, *) {
                scrollView.viewController?.setContentScrollView(scrollView)
            }

            if hDisableScroll || additionalSpaceFromTop > 0 {
                scrollView.bounces = false
            } else {
                scrollView.bounces = true
            }

        }
        .background(
            GeometryReader { proxy in
                Color.clear
                    .onAppear {
                        withAnimation {
                            scrollViewHeight = proxy.size.height
                            recalculateHeight()
                        }
                    }
                    .onChange(of: proxy.size) { size in
                        withAnimation {
                            scrollViewHeight = proxy.size.height
                            recalculateHeight()
                        }
                    }
            }
        )
    }

    @hColorBuilder
    static func returnTintColor() -> some hColor {
        hSignalColor.greenFill
    }

    func recalculateHeight() {
        let maxContentHeight =
            scrollViewHeight - bottomAttachedViewHeight - (UIApplication.shared.safeArea?.bottom ?? 0)
        if contentHeight <= maxContentHeight {
            self.additionalSpaceFromTop = {
                switch contentPosition {
                case .top: return 0
                case .center: return (maxContentHeight - contentHeight) / 2
                case .bottom: return scrollViewHeight - bottomAttachedViewHeight - contentHeight
                }
            }()
        } else {
            additionalSpaceFromTop = 0
        }
        if mergeBottomWithContentIfNeeded {
            let shouldMerge = scrollViewHeight - contentHeight - bottomAttachedViewHeight - 16 < 0
            scrollView?.bounces = shouldMerge
            mergeBottomViewWithContent = shouldMerge
        }
        shouldIgnoreTitleMargins = maxContentHeight - contentHeight < 100
    }
}

struct hForm_Previews: PreviewProvider {
    static var previews: some View {
        hForm {
            hSection {
                hText("Content").frame(height: 200).background(Color.red)
                hText("Content").frame(height: 200)
                hText("Content").frame(height: 200)
                hText("Content").frame(height: 200)
                    .background(Color.red)
            }
        }
        .hFormAttachToBottom {
            hButton.LargeButton(type: .primary) {

            } content: {
                hText("TEXT")
            }

        }
        .hFormContentPosition(.bottom)
        .hFormTitle(.small, .standard, "TITLE")
    }
}

//MARK: Enviroment keys
private struct EnvironmentHFormContentPosition: EnvironmentKey {
    static let defaultValue: ContentPosition = .top
}

extension EnvironmentValues {
    public var hFormContentPosition: ContentPosition {
        get { self[EnvironmentHFormContentPosition.self] }
        set { self[EnvironmentHFormContentPosition.self] = newValue }
    }
}

extension View {
    public func hFormContentPosition(_ position: ContentPosition) -> some View {
        self.environment(\.hFormContentPosition, position)
    }
}

public enum ContentPosition {
    case top
    case center
    case bottom
}

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

private struct EnvironmentHFormMergeBottomWithContentIfNeeded: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    public var hFormMergeBottomWithContentIfNeeded: Bool {
        get { self[EnvironmentHFormMergeBottomWithContentIfNeeded.self] }
        set { self[EnvironmentHFormMergeBottomWithContentIfNeeded.self] = newValue }
    }
}

extension View {
    public var hFormMergeBottomViewWithContentIfNeeded: some View {
        self.environment(\.hFormMergeBottomWithContentIfNeeded, true)
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
        view.subviews.forEach { subview in
            subview.backgroundColor = UIColor.clear
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

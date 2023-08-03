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

    @State var shouldAnimateGradient = true
    @State var bottomAttachedViewHeight: CGFloat = 0
    @State var scrollViewHeight: CGFloat = 0
    @State var contentHeight: CGFloat = 0
    @State var titleHeight: CGFloat = 0
    @State var additionalSpaceFromTop: CGFloat = 0

    @Environment(\.hFormBottomAttachedView) var bottomAttachedView
    @Environment(\.hFormTitle) var hFormTitle
    @Environment(\.hDisableScroll) var hDisableScroll
    @Environment(\.hFormContentPosition) var contentPosition
    var content: Content

    public init(
        @ViewBuilder _ builder: () -> Content
    ) {
        self.content = builder()
    }

    public var body: some View {
        VStack {
            if let hFormTitle {
                hText(hFormTitle.2, style: hFormTitle.1)
                    .multilineTextAlignment(.center)
                    .padding(.top, hFormTitle.0.topMargin)
                    .padding(.bottom, hFormTitle.0.bottomMargin)
                    .padding([.leading, .trailing], 16)
            }
            ZStack(alignment: .bottom) {
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
        }
        .background(
            BackgroundView().edgesIgnoringSafeArea(.all)
        )

    }

    func getScrollView() -> some View {
        ScrollView {
            Rectangle().fill(Color.clear).frame(height: additionalSpaceFromTop)
            content
                .background(
                    GeometryReader { proxy in
                        Color.clear
                            .onAppear {
                                contentHeight = proxy.size.height
                                recalculate()
                            }
                    }
                )
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
            recalculate()
        }
    }

    @hColorBuilder
    static func returnTintColor() -> some hColor {
        hSignalColorNew.greenFill
    }

    func recalculate() {
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
        print(
            "\(self.scrollViewHeight) - \(self.bottomAttachedViewHeight) = \(maxContentHeight) === \(self.contentHeight) === \(additionalSpaceFromTop)"
        )
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
            hButton.LargeButtonPrimary {

            } content: {
                hText("TEXT")
            }

        }
        .hFormContentPosition(.bottom)
        .hFormTitle(.small, .standard, "TITLE")
    }
}

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

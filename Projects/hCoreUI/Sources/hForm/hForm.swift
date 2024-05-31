import Combine
import Flow
import Foundation
import SwiftUI
import UIKit
import hCore

private enum AnimationKeys {
    static let bottomAnimationKey = "bottomAnimationKey"
}

public struct hForm<Content: View>: View, KeyboardReadable {
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
    @Environment(\.hFormIgnoreKeyboard) var hFormIgnoreKeyboard
    @Environment(\.hFormBottomBackgroundStyle) var bottomBackgroundStyle
    @Environment(\.hObserveKeyboard) var hObserveKeyboard
    @Environment(\.hIgnoreScrollOffsetChanges) var hIgnoreScrollOffsetChanges

    @Environment(\.colorScheme) private var colorScheme
    @State var lastTimeChangedMergeBottomViewWithContent = Date()
    @State var cancellable: AnyCancellable?
    @State var additionalContentOffset: CGFloat = 0
    @State var vc: UIViewController?
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
                if self.hFormIgnoreKeyboard {
                    getScrollView()
                        .clipped()
                        .ignoresSafeArea(.keyboard)
                } else {
                    getScrollView().clipped()
                }
            } else {
                if self.hFormIgnoreKeyboard {
                    getScrollView()
                        .ignoresSafeArea(.keyboard)
                } else {
                    getScrollView()
                }
            }
            if mergeBottomViewWithContent {
                Color.clear
                    .frame(maxHeight: bottomAttachedViewHeight, alignment: .bottom)
                    .opacity(0)
            } else {
                if bottomAttachedView != nil {
                    BackgroundBlurView()
                        .frame(
                            height: bottomAttachedViewHeight + (UIApplication.shared.safeArea?.bottom ?? 0),
                            alignment: .bottom
                        )
                        .offset(y: UIApplication.shared.safeArea?.bottom ?? 0)
                        .ignoresSafeArea(.all)
                    if self.hFormIgnoreKeyboard {
                        bottomAttachedViewWithModifier
                            .ignoresSafeArea(.keyboard)
                    } else {
                        bottomAttachedViewWithModifier
                    }

                }
            }
        }
        .background(
            BackgroundView().edgesIgnoringSafeArea(.all)
        )
    }

    private var bottomAttachedViewWithModifier: some View {
        bottomAttachedView
            .matchedGeometryEffect(id: AnimationKeys.bottomAnimationKey, in: animation)
            .background(
                GeometryReader { geo in
                    Color.clear
                        .onReceive(Just(geo.size.height)) { height in
                            if bottomAttachedViewHeight == 0 {
                                self.bottomAttachedViewHeight = height
                            } else {
                                self.bottomAttachedViewHeight = height
                                recalculateHeight()
                            }
                        }
                }
            )
            .frame(maxHeight: .infinity, alignment: .bottom)
    }

    func getScrollView() -> some View {
        ScrollView {
            if contentPosition != .bottom {
                Rectangle().fill(Color.clear).frame(height: additionalSpaceFromTop)
            }
            VStack(spacing: 8) {
                VStack(spacing: 0) {
                    if let hFormTitle {
                        VStack(alignment: hFormTitle.title.alignment == .leading ? .leading : .center) {
                            hText(hFormTitle.title.text, style: hFormTitle.title.fontSize)
                            if let subTitle = hFormTitle.subTitle {
                                hText(subTitle.text, style: subTitle.fontSize)
                                    .foregroundColor(hTextColor.secondary)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: hFormTitle.title.alignment)
                        .multilineTextAlignment(hFormTitle.title.alignment == .center ? .center : .leading)
                        .padding(.top, shouldIgnoreTitleMargins ? 0 : hFormTitle.title.type.topMargin)
                        .padding(.bottom, shouldIgnoreTitleMargins ? 0 : hFormTitle.title.type.bottomMargin)
                        .padding(.horizontal, 16)
                    }
                    if contentPosition == .bottom {
                        Rectangle().fill(Color.clear).frame(height: additionalSpaceFromTop)
                    }
                    content.padding(.vertical, -8)
                }
                .background(
                    GeometryReader { proxy in
                        hBackgroundColor.primary
                            .onAppear {
                                contentHeight = proxy.size.height
                                recalculateHeight()

                            }
                            .onChange(of: proxy.size) { size in
                                contentHeight = size.height
                                recalculateHeight()

                            }
                    }
                )
                if mergeBottomViewWithContent {
                    bottomAttachedView
                        .matchedGeometryEffect(id: AnimationKeys.bottomAnimationKey, in: animation)
                        .background(
                            GeometryReader { geo in
                                Color.clear
                                    .onReceive(Just(geo.size.height)) { height in
                                        if bottomAttachedViewHeight == 0 {
                                            self.bottomAttachedViewHeight = height
                                        } else {
                                            self.bottomAttachedViewHeight = height
                                            recalculateHeight()

                                        }
                                    }
                            }
                        )
                }
            }
            .frame(maxWidth: .infinity)
            .tint(hForm<Content>.returnTintColor())
            Color.clear
                .frame(height: mergeBottomWithContentIfNeeded ? 0 : bottomAttachedViewHeight)
        }
        .modifier(
            ForceScrollViewIndicatorInset(
                insetBottom: mergeBottomWithContentIfNeeded ? 0 : bottomAttachedViewHeight
            )
        )
        .modifier(
            ForceScrollViewTopInset(
                addedContentOffset: $additionalContentOffset,
                shouldFollow: hIgnoreScrollOffsetChanges
            )
        )
        .findScrollView { scrollView in
            if mergeBottomWithContentIfNeeded {
                self.scrollView = scrollView
            }
            scrollView.viewController?.setContentScrollView(scrollView, for: .top)

            if hDisableScroll || additionalSpaceFromTop > 0 {
                scrollView.bounces = false
            } else {
                scrollView.bounces = true
            }
            if hObserveKeyboard {
                cancellable = keyboardPublisher.sink { _ in
                } receiveValue: { [weak scrollView] keyboardHeight in
                    if let keyboardHeight {
                        if let view = UIResponder.currentFirstResponder as? UIView {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak scrollView] in
                                guard let scrollView = scrollView else { return }
                                let pointToCheck = CGPoint(x: 0, y: view.frame.size.height)
                                let positionToMove = view.convert(pointToCheck, to: scrollView).y

                                let moveTo = positionToMove + bottomAttachedViewHeight + keyboardHeight
                                scrollView.scrollRectToVisible(
                                    .init(
                                        x: 0,
                                        y: moveTo,
                                        width: view.frame.width,
                                        height: view.frame.height
                                    ),
                                    animated: true
                                )
                            }
                        }

                    }
                }
            }
        }
        .background(
            GeometryReader { proxy in
                Group {
                    switch bottomBackgroundStyle {
                    case let .gradient(from, to):

                        LinearGradient(
                            colors: [
                                from.colorFor(colorScheme, .base).color,
                                from.colorFor(colorScheme, .base).color,
                                to.colorFor(colorScheme, .base).color,
                                to.colorFor(colorScheme, .base).color,
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    case .transparent:
                        Color.clear
                    }
                }
                .onAppear {
                    scrollViewHeight = proxy.size.height
                    recalculateHeight()
                }
                .onChange(of: proxy.size) { size in
                    scrollViewHeight = proxy.size.height
                    recalculateHeight()
                }
            }
        )
        .onChange(of: additionalContentOffset) { newValue in
            recalculateHeight()
        }
    }

    @hColorBuilder
    static func returnTintColor() -> some hColor {
        hSignalColor.greenFill
    }

    func recalculateHeight() {
        let maxContentHeight = scrollViewHeight - bottomAttachedViewHeight
        var additionalSpaceFromTop: CGFloat = 0
        if contentHeight <= maxContentHeight {
            additionalSpaceFromTop = {
                switch contentPosition {
                case .top: return additionalContentOffset
                case .center: return (maxContentHeight - contentHeight) / 2
                case .bottom: return scrollViewHeight - bottomAttachedViewHeight - contentHeight
                }
            }()
        }

        var shouldMergeContent = false
        if mergeBottomWithContentIfNeeded {
            shouldMergeContent = mergeBottomViewWithContent
            scrollView?.bounces = mergeBottomViewWithContent
            let dateToCompareWith = Date()
            let value = lastTimeChangedMergeBottomViewWithContent.timeIntervalSince(dateToCompareWith)
            if value < -0.01 {
                let contentSize = scrollViewHeight - contentHeight - bottomAttachedViewHeight
                let shouldMerge = contentSize < 0
                lastTimeChangedMergeBottomViewWithContent = dateToCompareWith
                shouldMergeContent = shouldMerge
                scrollView?.bounces = shouldMerge
            }
        }

        let animated = self.additionalSpaceFromTop != additionalSpaceFromTop && additionalContentOffset == 0
        if animated {
            withAnimation {
                self.additionalSpaceFromTop = additionalSpaceFromTop
                self.mergeBottomViewWithContent = shouldMergeContent
            }
        } else {
            self.additionalSpaceFromTop = additionalSpaceFromTop
            self.mergeBottomViewWithContent = shouldMergeContent
        }
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
        .hFormBottomBackgroundColor(.gradient(from: hBackgroundColor.primary, to: hFillColor.opaqueOne))
        .hFormTitle(title: .init(.small, .standard, "TITLE"))
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

private struct EnvironmentHFormIgnoreKeyboard: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    public var hFormIgnoreKeyboard: Bool {
        get { self[EnvironmentHFormIgnoreKeyboard.self] }
        set { self[EnvironmentHFormIgnoreKeyboard.self] = newValue }
    }
}

extension View {
    public func hFormIgnoreKeyboard() -> some View {
        self.environment(\.hFormIgnoreKeyboard, true)
    }
}

public enum hFormBottomBackgroundStyle {
    case transparent
    case gradient(from: any hColor, to: any hColor)
}

private struct EnvironmentHFormBottomBackgorundColor: EnvironmentKey {
    static let defaultValue: hFormBottomBackgroundStyle = hFormBottomBackgroundStyle.transparent
}

extension EnvironmentValues {
    public var hFormBottomBackgroundStyle: hFormBottomBackgroundStyle {
        get { self[EnvironmentHFormBottomBackgorundColor.self] }
        set { self[EnvironmentHFormBottomBackgorundColor.self] = newValue }
    }
}

extension View {
    public func hFormBottomBackgroundColor(_ style: hFormBottomBackgroundStyle) -> some View {
        self.environment(\.hFormBottomBackgroundStyle, style)
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
    static let defaultValue: (title: hTitle, subTitle: hTitle?)? = nil
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

public struct hTitle {
    var type: HFormTitleSpacingType
    var fontSize: HFontTextStyle
    var text: String
    var alignment: Alignment

    public init(
        _ type: HFormTitleSpacingType,
        _ fontSize: HFontTextStyle,
        _ text: String,
        alignment: Alignment? = .center
    ) {
        self.type = type
        self.fontSize = fontSize
        self.text = text
        self.alignment = alignment ?? .center
    }
}

extension EnvironmentValues {
    public var hFormTitle: (title: hTitle, subTitle: hTitle?)? {
        get { self[EnvironmentHFormTitle.self] }
        set { self[EnvironmentHFormTitle.self] = newValue }
    }
}

extension View {
    public func hFormTitle(title: hTitle, subTitle: hTitle? = nil) -> some View {
        self.environment(\.hFormTitle, (title, subTitle))
    }
}

public struct BackgroundView: UIViewRepresentable {

    public init() {}
    public func updateUIView(_ uiView: UIViewType, context: Context) {
        uiView.backgroundColor = .brand(.primaryBackground())
    }

    public func makeUIView(context: Context) -> some UIView {
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

private struct EnvironmentHObserveKeyboard: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    public var hObserveKeyboard: Bool {
        get { self[EnvironmentHObserveKeyboard.self] }
        set { self[EnvironmentHObserveKeyboard.self] = newValue }
    }
}

extension View {
    public var hFormObserveKeyboard: some View {
        self.environment(\.hObserveKeyboard, true)
    }
}

private struct EnvironmentHIgnoreScrollOffsetChanges: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    public var hIgnoreScrollOffsetChanges: Bool {
        get { self[EnvironmentHIgnoreScrollOffsetChanges.self] }
        set { self[EnvironmentHIgnoreScrollOffsetChanges.self] = newValue }
    }
}

extension View {
    public var hFormIgnoreScrollOffsetChanges: some View {
        self.environment(\.hIgnoreScrollOffsetChanges, true)
    }
}

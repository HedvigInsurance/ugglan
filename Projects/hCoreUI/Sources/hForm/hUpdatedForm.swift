import Combine
import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect

public struct hUpdatedForm<Content: View>: View, KeyboardReadable {
    @Environment(\.hFormBottomAttachedView) var bottomAttachedView
    @Environment(\.hFormAlwaysVisibleBottomAttachedView) var hFormAlwaysVisibleBottomAttachedView
    @Environment(\.hFormTitle) var hFormTitle
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.hFormContentPosition) var contentPosition
    @Environment(\.hEnableScrollBounce) var hEnableScrollBounce
    @Environment(\.hFormBottomBackgroundStyle) var bottomBackgroundStyle
    @Environment(\.colorScheme) private var colorScheme

    @StateObject fileprivate var vm = hUpdatedFormViewModel()
    @Namespace var animationNamespace
    var content: Content

    public init(
        @ViewBuilder _ builder: () -> Content
    ) {
        self.content = builder()
    }
    public var body: some View {
        ZStack {
            BackgroundView().ignoresSafeArea()
            VStack(spacing: 0) {
                scrollView
                if !vm.keyboardVisible {
                    getAlwaysVisibleBottomView
                        .matchedGeometryEffect(id: "bottom", in: animationNamespace)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(maxHeight: .infinity)
            .background {
                GeometryReader { geometry in
                    hBackgroundColor.primary
                        .onAppear {
                            vm.viewHeight = geometry.size.height
                        }
                        .onChange(of: geometry.size) { value in
                            vm.viewHeight = value.height
                        }
                }
            }
        }
        .task {
            vm.scrollBounces = hEnableScrollBounce
        }
    }

    private var scrollView: some View {
        GeometryReader { geometry in
            ScrollView {
                centerContent
                    .frame(minHeight: contentPosition == .compact ? nil : geometry.size.height)
                    .frame(maxWidth: .infinity)
                    .frame(maxHeight: .infinity)
                    .background {
                        GeometryReader { geometry in
                            hBackgroundColor.primary
                                .onAppear {
                                    vm.scrollViewHeight = geometry.size.height
                                }
                                .onChange(of: geometry.size) { value in
                                    vm.scrollViewHeight = value.height
                                }
                        }
                    }
            }
            .frame(maxWidth: .infinity)
            .frame(maxHeight: .infinity)
            .introspect(.scrollView, on: .iOS(.v13...)) { [weak vm] scrollView in
                guard let vm else { return }
                if scrollView != vm.scrollView {
                    vm.scrollView = scrollView
                    vm.keyboardCancellable = keyboardPublisher.sink { _ in
                    } receiveValue: { [weak vm] keyboardHeight in
                        vm?.keyboardVisible = keyboardHeight != nil
                    }
                }
            }
            .introspect(.viewController, on: .iOS(.v13...)) { [weak vm] vc in
                vm?.vc = vc
            }
            .background {
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
            }
        }
    }

    private var centerContent: some View {
        VStack(spacing: 0) {
            switch contentPosition {
            case .top:
                formTitle
                    .layoutPriority(1)
                content
                Spacer(minLength: 0)
                    .layoutPriority(1)
                getBottomAttachedView
            case .center:
                formTitle
                Spacer(minLength: 0)
                content
                Spacer(minLength: 0)
                getBottomAttachedView
            case .bottom:
                formTitle
                Spacer()
                content
                getBottomAttachedView
            case .compact:
                formTitle
                content
                getBottomAttachedView
            }
            if vm.keyboardVisible {
                getAlwaysVisibleBottomView
                    .matchedGeometryEffect(id: "bottom", in: animationNamespace)
            }
        }
    }

    @ViewBuilder
    private var formTitle: some View {
        if let hFormTitle {
            VStack(alignment: hFormTitle.title.alignment == .leading ? .leading : .center, spacing: 0) {
                hText(hFormTitle.title.text, style: hFormTitle.title.fontSize)
                if let subTitle = hFormTitle.subTitle {
                    hText(subTitle.text, style: subTitle.fontSize)
                        .foregroundColor(hTextColor.Opaque.secondary)
                        .multilineTextAlignment(hFormTitle.title.alignment == .center ? .center : .leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: hFormTitle.title.alignment)
            .multilineTextAlignment(hFormTitle.title.alignment == .center ? .center : .leading)
            .padding(.top, hFormTitle.title.type.topMargin)
            .padding(
                .bottom,
                hFormTitle.subTitle?.type.bottomMargin ?? hFormTitle.title.type.bottomMargin
            )
            .padding(.horizontal, horizontalSizeClass == .regular ? .padding60 : .padding16)
        }
    }

    @ViewBuilder
    private var getBottomAttachedView: some View {
        if hFormAlwaysVisibleBottomAttachedView != nil {
            bottomAttachedView
        } else {
            bottomAttachedView?.padding(.bottom, .padding16)
        }
    }

    @ViewBuilder
    private var getAlwaysVisibleBottomView: some View {
        hFormAlwaysVisibleBottomAttachedView
            .padding(.top, .padding16)
            .padding(.bottom, .padding16)
            .background {
                BackgroundBlurView()
                    .ignoresSafeArea()
            }
    }
}

#Preview {
    hUpdatedForm {
        hText("Main content")
        Rectangle().frame(width: 100, height: 100)
        Rectangle().frame(width: 100, height: 100)
        Rectangle().frame(width: 100, height: 100)
        Rectangle().fill(Color.red.opacity(0.1)).frame(width: 300, height: 300)
        Rectangle().fill(Color.blue.opacity(0.1)).frame(width: 300, height: 300)

    }
    .hFormAttachToBottom {
        hText("BOTTOM")
    }
    .hFormAlwaysAttachToBottom {
        hSection {
            hText("Always visible content")
        }
        .sectionContainerStyle(.transparent)
    }
    .hFormTitle(title: .init(.small, .body1, "title", alignment: .leading), subTitle: nil)
}

@MainActor
private class hUpdatedFormViewModel: ObservableObject {

    var keyboardCancellable: AnyCancellable?
    @Published var keyboardVisible: Bool = false
    weak var scrollView: UIScrollView? {
        didSet {
            scrollView?.clipsToBounds = false
            setScrollView()
            setBouces()
        }
    }
    weak var vc: UIViewController? {
        didSet {
            setScrollView()
        }
    }

    var viewHeight: CGFloat = 0 {
        didSet {
            setBouces()
        }
    }

    var scrollViewHeight: CGFloat = 0 {
        didSet {
            setBouces()
        }
    }

    var scrollBounces: Bool? = nil {
        didSet {
            setBouces()
        }
    }

    private func setBouces() {
        if let scrollBounces {
            scrollView?.bounces = scrollBounces
        } else {
            if scrollViewHeight - 1 > viewHeight {
                scrollView?.bounces = true
            } else {
                scrollView?.bounces = false
            }
        }
    }

    private func setScrollView() {
        if let vc, let scrollView {
            vc.setContentScrollView(scrollView)
        }
    }
}

private struct EnvironmentHScrollBounce: EnvironmentKey {
    static let defaultValue: Bool? = nil
}

extension EnvironmentValues {
    public var hEnableScrollBounce: Bool? {
        get { self[EnvironmentHScrollBounce.self] }
        set { self[EnvironmentHScrollBounce.self] = newValue }
    }
}

extension View {
    /// Used to determine if we should bounce effect on the scroll view
    /// nil: default behaviour depending on the content position and content size
    /// true: always on
    /// false : always off
    public func hSetScrollBounce(to value: Bool?) -> some View {
        self.environment(\.hEnableScrollBounce, value)
    }
}

@MainActor
private struct EnvironmentHFormAlwaysVisibleBottomAttachedView: @preconcurrency EnvironmentKey {
    static let defaultValue: AnyView? = nil
}

extension EnvironmentValues {
    public var hFormAlwaysVisibleBottomAttachedView: AnyView? {
        get { self[EnvironmentHFormAlwaysVisibleBottomAttachedView.self] }
        set { self[EnvironmentHFormAlwaysVisibleBottomAttachedView.self] = newValue }
    }
}

extension View {
    /// View that is not part of the scroll view, but just bellow it ignoring keyboard. Default spacing to top and bottom are added to this view
    public func hFormAlwaysAttachToBottom<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        self.environment(\.hFormAlwaysVisibleBottomAttachedView, AnyView(content()))
    }
}

@MainActor
private struct EnvironmentHFormContentPosition: @preconcurrency EnvironmentKey {
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
    case compact
}

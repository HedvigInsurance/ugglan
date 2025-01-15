import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect

public struct hUpdatedForm<Content: View>: View {
    @Environment(\.hFormBottomAttachedView) var bottomAttachedView
    @Environment(\.hFormTitle) var hFormTitle
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.hFormContentPosition) var contentPosition
    @Environment(\.hEnableScrollBounce) var hEnableScrollBounce
    @StateObject fileprivate var vm = hUpdatedFormViewModel()
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
                GeometryReader { geometry in
                    ScrollView {
                        centerContent
                            .frame(minHeight: geometry.size.height)
                            .frame(maxWidth: .infinity)
                            .frame(maxHeight: .infinity)
                            .background {
                                GeometryReader { geometry in
                                    Color.clear
                                        .onAppear {
                                            vm.contentHeight = geometry.size.height
                                        }
                                        .onChange(of: geometry.size) { value in
                                            vm.contentHeight = value.height
                                        }
                                }
                            }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(maxHeight: .infinity)
                    .introspect(.scrollView, on: .iOS(.v13...)) { scrollView in
                        vm.scrollView = scrollView
                    }
                    .introspect(.viewController, on: .iOS(.v13...)) { vc in
                        vm.vc = vc
                    }
                    .background {
                        Color.clear
                            .onAppear {
                                vm.viewHeight = geometry.size.height
                            }
                            .onChange(of: geometry.size) { value in
                                vm.viewHeight = value.height
                            }
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(maxHeight: .infinity)
        }
        .task {
            vm.scrollBounces = hEnableScrollBounce
        }
    }

    private var centerContent: some View {
        VStack(spacing: 0) {
            switch contentPosition {
            case .top:
                formTitle
                content
                Spacer(minLength: 0)
                    .layoutPriority(1)
                bottomAttachedView
            case .center:
                formTitle
                Spacer(minLength: 0)
                content
                Spacer(minLength: 0)
                bottomAttachedView
            case .bottom:
                formTitle
                Spacer(minLength: 0)
                    .layoutPriority(1)
                content
                bottomAttachedView
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
}

#Preview {
    hUpdatedForm {
        hText("Main content")
        Rectangle().frame(width: 100, height: 100)
        Rectangle().frame(width: 100, height: 100)
        Rectangle().frame(width: 100, height: 100)
        Rectangle().frame(width: 300, height: 300)
    }
    .hFormAttachToBottom {
        hText("BOTTOM")
    }
    .hFormTitle(title: .init(.small, .body1, "title", alignment: .leading), subTitle: nil)
}

@MainActor
private class hUpdatedFormViewModel: ObservableObject {
    weak var scrollView: UIScrollView? {
        didSet {
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

    var contentHeight: CGFloat = 0 {
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
            if contentHeight > viewHeight {
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
    public func hSetScrollBounce(to value: Bool?) -> some View {
        self.environment(\.hEnableScrollBounce, value)
    }
}

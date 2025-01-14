import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect

public struct hUpdatedForm<Content: View>: View {
    @Environment(\.hFormBottomAttachedView) var bottomAttachedView
    @Environment(\.hFormTitle) var hFormTitle
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.hFormContentPosition) var contentPosition
    @State var contentHeight: CGFloat = 0
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
                                            contentHeight = geometry.size.height
                                        }
                                        .onChange(of: geometry.size) { value in
                                            contentHeight = value.height
                                        }
                                }
                            }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(maxHeight: .infinity)
                    .introspect(.scrollView, on: .iOS(.v13...)) { scrollView in
                        if contentHeight > geometry.size.height {
                            scrollView.bounces = true
                        } else {
                            scrollView.bounces = false
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(maxHeight: .infinity)
        }
    }

    private var centerContent: some View {
        VStack(spacing: 0) {
            switch contentPosition {
            case .top:
                formTitle
                content
                Spacer()
                bottomAttachedView
            case .center:
                formTitle
                Spacer()
                content
                Spacer()
                bottomAttachedView
            case .bottom:
                formTitle
                Spacer()
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

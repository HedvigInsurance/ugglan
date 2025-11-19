import SwiftUI

public struct ExpandingView: View {
    let mainContent: AnyView
    let expandingContent: AnyView
    @State private var expanded = false
    @State var animation: Animation?
    let spacing: CGFloat
    let delay: Float
    let finalView: (AnyView) -> AnyView

    public init<MainView: View, AddedView: View>(
        @ViewBuilder mainContent: @escaping () -> MainView,
        @ViewBuilder expandingContent: @escaping () -> AddedView,
        spacing: CGFloat = .padding8,
        delay: Float = 1,
        finalView: @escaping (AnyView) -> AnyView = { $0 }
    ) {
        self.mainContent = AnyView(mainContent())
        self.expandingContent = AnyView(expandingContent())
        self.spacing = spacing
        self.delay = delay
        self.finalView = finalView
    }

    public var body: some View {
        finalView(
            AnyView(
                HStack(spacing: spacing) {
                    mainContent
                    if expanded {
                        expandingContent
                    }
                }
                .onAppear {
                    Task {
                        animation = nil
                        expanded = false
                        try? await Task.sleep(seconds: delay)
                        animation = .easeInOut(duration: 1)
                        expanded = true
                    }
                }
            )
        )
        .animation(animation, value: expanded)
    }
}

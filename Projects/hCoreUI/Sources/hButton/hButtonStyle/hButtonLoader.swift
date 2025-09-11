import SwiftUI

struct LoaderOrContent<Content: View>: View {
    @Environment(\.hButtonIsLoading) var isLoading
    @Environment(\.hButtonConfigurationType) var configurationType
    @Environment(\.hButtonDontShowLoadingWhenDisabled) var dontShowLoadingWhenDisabled
    @Environment(\.colorScheme) var colorScheme

    private let content: () -> Content
    private let color: any hColor

    init(
        color: any hColor,
        @ViewBuilder _ content: @escaping () -> Content
    ) {
        self.color = color
        self.content = content
    }

    var body: some View {
        if shouldShowLoading {
            loadingIndicator
                .fixedSize(horizontal: false, vertical: true)
        } else {
            content()
        }
    }

    @ViewBuilder
    private var loadingIndicator: some View {
        let useDark = configurationType.shouldUseDark(for: colorScheme)
        if useDark {
            DotsActivityIndicator(.standard)
                .modifier(DarkIndicatorStyle())
        } else {
            DotsActivityIndicator(.standard)
        }
    }

    private var shouldShowLoading: Bool {
        isLoading && !dontShowLoadingWhenDisabled
    }
}

private struct DarkIndicatorStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .useDarkColor
            .colorScheme(.light)
    }
}

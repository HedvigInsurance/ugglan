import SwiftUI

struct LoaderOrContent<Content: View>: View {
    @Environment(\.hButtonIsLoading) var isLoading
    @Environment(\.hButtonConfigurationType) var configurationType
    @Environment(\.hButtonDontShowLoadingWhenDisabled) var dontShowLoadingWhenDisabled
    @Environment(\.colorScheme) var colorScheme

    private let content: () -> Content

    init(
        @ViewBuilder _ content: @escaping () -> Content
    ) {
        self.content = content
    }

    var body: some View {
        ZStack {
            if shouldShowLoading {
                loadingIndicator
                    .fixedSize(horizontal: false, vertical: true)
            }
            content().opacity(shouldShowLoading ? 0 : 1)
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

import SwiftUI

struct LoaderOrContent<Content: View>: View {
    @Environment(\.hButtonIsLoading) var isLoading
    @Environment(\.hButtonConfigurationType) var hButtonConfigurationType
    @Environment(\.isEnabled) var enabled
    @Environment(\.hButtonDontShowLoadingWhenDisabled) var dontShowLoadingWhenDisabled
    @Environment(\.colorScheme) var colorScheme
    var content: () -> Content
    var color: any hColor

    init(
        color: any hColor,
        @ViewBuilder _ content: @escaping () -> Content
    ) {
        self.color = color
        self.content = content
    }

    var body: some View {
        if isLoading && !dontShowLoadingWhenDisabled {
            Group {
                if hButtonConfigurationType.shouldUseDark(for: colorScheme) {
                    DotsActivityIndicator(.standard)
                        .useDarkColor
                        .colorScheme(.light)
                } else {
                    DotsActivityIndicator(.standard)
                }
            }
            .fixedSize(horizontal: false, vertical: true)
        } else {
            content()
        }
    }
}

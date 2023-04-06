import SwiftUI
import hCore

public struct RetryView1: View {
    var title: String
    var retryTitle: String
    var action: (() -> Void)

    public init(
        title: String,
        retryTitle: String,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.retryTitle = retryTitle
        self.action = action
    }

    public var body: some View {
        hSection {
            Group {
                hText(L10n.somethingWentWrong)
                hText(title, style: .body).multilineTextAlignment(.center)
                hButton.SmallButtonFilled {
                    action()
                } content: {
                    hText(retryTitle)
                }
            }
            .padding(20)
        }
        .hShadow()
    }
}

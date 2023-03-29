import SwiftUI
import hCore

public struct RetryView: View {
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
        hForm {
            hText(L10n.somethingWentWrong)
            hText(title, style: .body).multilineTextAlignment(.center)
                .padding(20)
            hButton.SmallButtonFilled {
                action()
            } content: {
                hText(retryTitle)
            }
            .padding(.horizontal, 10)
        }
        //        VStack {
        //            Spacer()
        //            hText(title, style: .body).multilineTextAlignment(.center)
        //            Spacer(minLength: 40)
        //            hButton.LargeButtonFilled {
        //                action()
        //            } content: {
        //                hText(retryTitle)
        //            }
        //        }
    }
}

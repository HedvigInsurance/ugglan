import SwiftUI
import hCore
import hCoreUI

struct LoginErrorView: View {
    let message: String
    @EnvironmentObject var router: Router
    var body: some View {
        GenericErrorView(
            description: message,
            buttons: .init(
                dismissButton: .init(
                    buttonTitle: L10n.generalCloseButton,
                    buttonAction: {
                        router.pop()
                    }
                )
            )
        )
    }
}

#Preview{
    LoginErrorView(message: "message")
}

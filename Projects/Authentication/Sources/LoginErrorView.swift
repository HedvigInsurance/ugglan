import SwiftUI
import hCore
import hCoreUI

public struct LoginErrorView: View {
    let message: String
    @EnvironmentObject var router: Router

    public init(message: String) {
        self.message = message
    }

    public var body: some View {
        GenericErrorView(
            description: message
        )
        .hErrorViewButtonConfig(
            .init(
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

#Preview {
    LoginErrorView(message: "message")
}

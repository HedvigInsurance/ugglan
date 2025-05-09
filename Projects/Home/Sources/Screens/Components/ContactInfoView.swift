import SwiftUI
import hCoreUI

struct ContactInfoView: View {
    @EnvironmentObject var router: Router

    var body: some View {
        InfoCard(
            text: "Make sure we’ve got the right contact info in case we need to reach you.",
            type: .info
        )
        .buttons(
            [
                .init(
                    buttonTitle: "Update contact info",
                    buttonAction: {
                        router.push(HomeRouterActions.contactInfo)
                    }
                )
            ]
        )
    }

}

import SwiftUI
import hCore
import hCoreUI

struct ContactInfoView: View {
    @EnvironmentObject var router: Router
    @EnvironmentObject var homeVm: HomeNavigationViewModel

    var body: some View {
        InfoCard(
            text: L10n.missingContactInfoCardText,
            type: .info
        )
        .buttons(
            [
                .init(
                    buttonTitle: L10n.missingContactInfoCardButton,
                    buttonAction: {
                        homeVm.pushToProfile?()
                    }
                )
            ]
        )
    }
}

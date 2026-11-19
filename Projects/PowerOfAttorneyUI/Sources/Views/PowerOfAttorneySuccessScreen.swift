import PowerOfAttorneyCore
import SwiftUI
import hCore
import hCoreUI

struct PowerOfAttorneySuccessScreen: View {
    let user: PowerOfAttorneyUser
    let shareUrl: URL
    @Environment(NavigationRouter.self) private var router

    var body: some View {
        StateView(
            type: .success,
            // TODO: Localize via Lokalise
            title: "Power of attorney signed",
            // TODO: Localize via Lokalise
            bodyText: "Share the link with \(user.fullName) so they can use the power of attorney."
        )
        .hStateViewBottomAttachedView {
            hSection {
                VStack(spacing: .padding8) {
                    // TODO: Localize "Share" via Lokalise
                    PopoverShareButton(url: shareUrl, title: "Share", size: .large, type: .primary)
                    hButton(
                        .large,
                        .ghost,
                        content: .init(title: L10n.generalDoneButton)
                    ) {
                        // Closes the add power of attorney flow
                        router.dismiss()
                    }
                }
                .padding(.bottom, .padding16)
            }
            .sectionContainerStyle(.transparent)
        }
    }
}

#Preview {
    PowerOfAttorneySuccessScreen(
        user: .init(id: "1", firstName: "Anna", lastName: "Andersson", ssn: "199001011234"),
        shareUrl: URL(string: "https://www.hedvig.com")!
    )
    .environment(NavigationRouter())
}

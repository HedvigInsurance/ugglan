import SwiftUI
import hCore
import hCoreUI

public struct SubmitClaimDeflectMessageStepView: View {
    private let model: ClaimIntentStepContentDeflectionMessage
    @EnvironmentObject var router: NavigationRouter
    public init(
        model: ClaimIntentStepContentDeflectionMessage,
    ) {
        self.model = model
    }

    public var body: some View {
        hSection {
            hButton(
                .large,
                .primary,
                content: .init(title: L10n.generalCloseButton)
            ) {
                router.dismiss()
            }
        }
        .sectionContainerStyle(.transparent)
    }
}

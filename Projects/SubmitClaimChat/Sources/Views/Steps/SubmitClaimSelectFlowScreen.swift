import SwiftUI
import hCore
import hCoreUI

struct SubmitClaimSelectFlowScreen: View {
    @EnvironmentObject var router: Router
    let action: (ClaimAction) -> Void

    init(
        action: @escaping (ClaimAction) -> Void
    ) {
        self.action = action
    }

    var body: some View {
        hForm {
            VStack(alignment: .leading, spacing: .padding8) {
                HStack(spacing: .padding8) {
                    hButton(.medium, .secondaryAlt, content: .init(title: "AI claim")) {
                        action(.automationSubmitClaim)
                    }
                    .withGradientBorder(shape: RoundedRectangle(cornerRadius: .padding8))
                    hButton(.medium, .secondaryAlt, content: .init(title: "Dev AI claim")) {
                        action(.devAutomationSubmitClaim)
                    }
                    .withGradientBorder(shape: RoundedRectangle(cornerRadius: .padding8))
                }
                .hButtonTakeFullWidth(true)

                hCancelButton {
                    router.dismiss()
                }
            }
            .padding(.horizontal, .padding24)
            .padding(.top, -8)
        }
        .hFormContentPosition(.compact)
    }
}

enum ClaimAction {
    case automationSubmitClaim
    case devAutomationSubmitClaim
}

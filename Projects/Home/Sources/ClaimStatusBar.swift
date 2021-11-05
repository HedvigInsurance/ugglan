import SwiftUI
import hGraphQL
import hCoreUI
import hCore

struct ClaimStatusBar: View {
    let status: Claim.ClaimStatus
    @State var currentStatus: Claim.ClaimStatus
    
    
    @hColorBuilder var barColor: some hColor {
        switch (status, currentStatus) {
        case (.reopened, .reopened):
            hTintColor.orangeOne
        case (_, .closed):
            hTintColor.lavenderOne
        case (let x, let y) where x == y:
            hLabelColor.primary
        case (.submitted, .beingHandled):
            hLabelColor.secondary
        case (.beingHandled, .submitted):
            hLabelColor.tertiary
        case (.closed, _):
            hLabelColor.tertiary
        default:
            hTintColor.lavenderOne
        }
    }
    
    @hColorBuilder var textColor: some hColor {
        switch (status, currentStatus) {
        case (_, .closed):
            hLabelColor.primary
        case (let x, let y) where x == y:
            hLabelColor.primary
        case (.submitted, .beingHandled):
            hLabelColor.secondary
        case (.beingHandled, .submitted):
            hLabelColor.tertiary
        case (.closed, _):
            hLabelColor.tertiary
        default:
            hTintColor.lavenderOne
        }
    }
    
    var body: some View {
        VStack {
            Rectangle()
                .fill(barColor)
                .frame(height: 4)
            hText(status.text ?? "", style: .caption1)
                .foregroundColor(textColor)
        }.frame(maxWidth: .infinity)
    }
}

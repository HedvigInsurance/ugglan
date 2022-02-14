import SwiftUI
import Presentation
import hCore
import hCoreUI
import Flow

struct HowClaimsWorkButton: View {
    @PresentableStore var store: ClaimsStore
    
    var body: some View {
        Button {
            store.send(.openHowClaimsWork)
        } label: {
            HStack(spacing: 7) {
                hCoreUIAssets.infoSmall.view
                    .resizable()
                    .foregroundColor(hLabelColor.primary)
                    .frame(width: 14, height: 14)
                
                hText(L10n.ClaimsExplainer.title, style: .body)
                    .foregroundColor(hLabelColor.primary)
            }
        }
    }
}

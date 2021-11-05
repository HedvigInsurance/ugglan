import SwiftUI
import hCore
import hGraphQL
import hCoreUI

struct ClaimSection: View {
    var claims: [Claim]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(claims, id: \.id) { claim in
                    ClaimStatus(claim: claim)
                        .frame(width: UIScreen.main.bounds.width * 0.8)
                        .padding([.top, .bottom, .trailing])
                }
            }
        }.frame(maxWidth: .infinity)
    }
}


#if DEBUG

struct ClaimSectionPreview: PreviewProvider {
    static var previews: some View {
        ClaimSection(claims: [.mock, .mock]).preferredColorScheme(.light).previewAsComponent()
    }
}
#endif

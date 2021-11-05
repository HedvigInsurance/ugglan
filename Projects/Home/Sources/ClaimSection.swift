import SwiftUI
import hCore
import hGraphQL
import hCoreUI
import Combine

struct ClaimSection: View {
    var claims: [Claim]
    @State var frameWidth: CGFloat = 0
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(claims, id: \.id) { claim in
                    ClaimStatus(claim: claim)
                        .frame(width: frameWidth * 0.8)
                        .padding([.top, .bottom, .trailing])
                }
            }
        }
        .background(
            GeometryReader { geo in
                Color.clear.onReceive(Just(geo.size.width)) { width in
                    self.frameWidth = width
                }
            }
        )
    }
}


#if DEBUG

struct ClaimSectionPreview: PreviewProvider {
    static var previews: some View {
        ClaimSection(claims: [.mock, .mock]).preferredColorScheme(.light).previewAsComponent()
    }
}
#endif

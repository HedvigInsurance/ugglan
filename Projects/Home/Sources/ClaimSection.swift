import Combine
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct ClaimSection: View {
    @State var claims: [Claim]
    @State var frameWidth: CGFloat = 0

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(claims, id: \.id) { claim in
                    ClaimStatus(claim: claim)
                        .frame(width: frameWidth * 0.8)
                        .padding([.top, .bottom, .trailing])
                }
            }.padding([.leading], 14)
        }
        .padding([.leading, .trailing], -14)
        .background(
            GeometryReader { geo in
                Color.clear.onReceive(Just(geo.size.width)) { width in
                    self.frameWidth = width
                }
            }
        )
    }
}


struct ClaimSectionPreview: PreviewProvider {
    static var previews: some View {
        ClaimSection(claims: [.mock, .mock]).preferredColorScheme(.light).previewAsComponent()
    }
}

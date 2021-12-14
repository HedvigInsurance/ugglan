import SwiftUI
import hCoreUI
import hCore
import hGraphQL

public struct ClaimDetailView: View {
    var claim: Claim
    
    public init(claim: Claim) {
        self.claim = claim
    }
    
    public var body: some View {
        VStack {
            TappableCard {
                HStack(spacing: 6) {
                    ForEach(claim.segments, id: \.text) { segment in
                        ClaimStatusBar(status: segment)
                    }
                }
                .padding(16)
                
                Spacer()
                    .frame(maxHeight: 8)
                
                hText("We have received your claim and will start reviewing it soon.")
                    .multilineTextAlignment(.leading)
                
                Spacer()
                    .frame(maxHeight: 20)
                Divider()
                
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 3) {
                        hText("Questions", style: .caption1)
                            .foregroundColor(hLabelColor.secondary)
                        hText("Contact us in the chat", style: .callout)
                    }
                    Spacer()
                    Image(uiImage: hCoreUIAssets.chat.image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                }
                .padding(16)
            }
            .padding([.leading, .trailing], 16)
        }
    }
}

import SwiftUI
import hCore
import hCoreUI
import hGraphQL

public struct ClaimDetailView: View {
    var claim: Claim

    public init(
        claim: Claim
    ) {
        self.claim = claim
    }

    public var body: some View {
        VStack {
            // Claim status header
            VStack(alignment: .center) {
                // TODO: Add Image as computed property
                hCoreUIAssets.infoShield.view
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 18, height: 22)

                // TODO: Add title as a computed property
                hText("New insurance case", style: .headline)

                Spacer()
                    .frame(height: 16)

                HStack {
                    Spacer()
                    VStack(spacing: 4) {
                        hText("Submitted", style: .caption2)
                            .foregroundColor(hLabelColor.secondary)

                        // TODO: Parse submitted time into readable format
                        hText("1 min ago", style: .caption1)
                    }

                    Spacer()
                    Divider()
                        .frame(maxHeight: 32)

                    Spacer()
                    VStack(spacing: 4) {
                        hText("Closed", style: .caption2)
                            .foregroundColor(hLabelColor.secondary)

                        // TODO: Show closed time from a computed property
                        hText("-", style: .caption1)
                    }
                    Spacer()
                }
            }

            Spacer()
                .frame(height: 24)

            TappableCard(alignment: .leading) {
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
                    .padding(.horizontal, 16)

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
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: .defaultCornerRadius)
                            .fill(hBackgroundColor.primary)
                            .frame(width: 40, height: 40)
                        
                        hCoreUIAssets.chatSolid.view
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 23, height: 19)
                    }
                }
                .padding(16)
            }
            .padding(.horizontal, 16)

            Spacer()
        }
    }
}

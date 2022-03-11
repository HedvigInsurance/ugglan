import Foundation
import SwiftUI
import hCore
import hCoreUI

struct CrossSellingHeroImageModifier: ViewModifier {
    var scrollView: UIScrollView
    var contentOffset: CGPoint

    func body(content: Content) -> some View {
        content
            .padding(.top, -scrollView.adjustedContentInset.top)
            .transformEffect(
                .init(
                    translationX: 0,
                    y: min(scrollView.contentOffset.y + scrollView.adjustedContentInset.top, 0)
                )
            )
    }
}

struct CrossSellingHeroImage: View {
    let imageURL: URL
    let blurHash: String

    var body: some View {
        VStack {
            LinearGradient(
                gradient: Gradient(
                    colors: [.black.opacity(0.5), .clear]
                ),
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .frame(height: 250)
        .backgroundImageWithBlurHashFallback(imageURL: imageURL, blurHash: blurHash)
        .clipped()
        .modifier(
            ContentOffsetModifier { scrollView, contentOffset in
                CrossSellingHeroImageModifier(scrollView: scrollView, contentOffset: contentOffset)
            }
        )
    }
}

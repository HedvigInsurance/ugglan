import Foundation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct CrossSellingCardButtonStyle: SwiftUI.ButtonStyle {
    let crossSell: hGraphQL.CrossSell
    
    func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .background(Group {
                if configuration.isPressed {
                    hOverlayColor.pressed.opacity(0.2)
                } else {
                    Color.clear
                }
            })
            .background(
                LinearGradient(
                    gradient: Gradient(
                        colors: [.black.opacity(0.5), .clear]
                    ),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .backgroundImageWithBlurHashFallback(
                imageURL: crossSell.imageURL,
                blurHash: crossSell.blurHash
            )
            .cornerRadius(.defaultCornerRadius)
            .shadow(color: .black.opacity(0.05), radius: 24, x: 0, y: 4)
    }
}

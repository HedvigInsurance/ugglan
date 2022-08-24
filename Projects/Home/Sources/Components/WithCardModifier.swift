import Foundation
import SwiftUI

struct WithCard<Card: View>: ViewModifier {
    var card: () -> Card
    @State private var rect1: CGRect = CGRect()

    func body(content: Content) -> some View {
        VStack {
            content
            card()
                .padding(.top, 32)
        }
    }
}

extension View {
    func addStatusCard<Card: View>(_ card: @escaping () -> Card) -> some View {
        modifier(WithCard(card: card))
    }
}

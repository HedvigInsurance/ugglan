import Foundation
import SwiftUI

struct WithCard<Card: View>: ViewModifier {
    var card: () -> Card

    func body(content: Content) -> some View {
        VStack {
            content
            card()
        }
    }
}

extension View {
    func addStatusCard<Card: View>(_ card: @escaping () -> Card) -> some View {
        modifier(WithCard(card: card))
    }
}

import SwiftUI
import hCore
import hCoreUI

struct CircularProgressView: View {
    @State private var isAnimating = false

    var body: some View {
        Circle()
            .stroke(hBorderColor.secondary, lineWidth: 2)
            .frame(width: 16, height: 16)
            .overlay {
                Circle()
                    .trim(from: 0, to: 0.25)
                    .stroke(hSignalColor.Green.element, lineWidth: 2)
                    .rotationEffect(.degrees(isAnimating ? 360 : 0))
                    .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: isAnimating)
            }
            .onAppear {
                isAnimating = true
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(L10n.embarkLoading)
            .accessibilityAddTraits(.updatesFrequently)
    }
}

#Preview {
    CircularProgressView()
}

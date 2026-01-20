import SwiftUI
import hCoreUI

struct AnimatedDotView: View {
    @State private var show = true

    private let timer = Timer.publish(every: 0.4, on: .main, in: .common).autoconnect()

    var body: some View {
        Circle()
            .fill(hSignalColor.Green.element)
            .frame(width: 14, height: 14)
            .opacity(show ? 1 : 0)
            .onReceive(timer) { _ in
                show.toggle()
            }
            .transition(.opacity)
            .accessibilityHidden(true)
    }
}

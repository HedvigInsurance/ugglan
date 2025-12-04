import SwiftUI
import hCoreUI

struct CircularProgressView: View {
    @State private var angle = Angle(degrees: 0)

    private let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    var body: some View {
        Circle()
            .stroke(hBorderColor.secondary, lineWidth: 2)
            .frame(width: 16, height: 16)
            .onReceive(timer) { _ in
                angle += .degrees(90)
            }
            .overlay {
                Circle()
                    .trim(from: 0, to: 0.25)
                    .stroke(hSignalColor.Green.element, lineWidth: 2)
                    .rotationEffect(angle)
                    .animation(.linear(duration: 0.25), value: angle)
            }
            .onAppear {
                angle += .degrees(90)
            }
    }
}

#Preview {
    CircularProgressView()
}

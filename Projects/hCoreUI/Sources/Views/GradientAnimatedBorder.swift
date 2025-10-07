import SwiftUI

extension View {
    public func withGradientBorder<S: Shape>(shape: S) -> some View {
        self.modifier(GradientShapeBorderViewModifier(shape: shape))
    }
}

private struct GradientShapeBorderViewModifier<S: Shape>: ViewModifier {
    @State private var angle: Angle = .degrees(0)
    private let timer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()
    let shape: S

    init(
        shape: S
    ) {
        self.shape = shape
    }

    func body(content: Content) -> some View {
        content
            .clipShape(shape)
            .overlay {
                shape.stroke(
                    gradient,
                    lineWidth: 2
                )
            }
            .onReceive(timer) { _ in
                animateGradient()
            }
            .onAppear {
                animateGradient()
            }
    }

    private var gradient: AngularGradient {
        AngularGradient(
            stops: [
                Gradient.Stop(color: Color(red: 0.74, green: 0.51, blue: 0.95), location: 0.17),
                Gradient.Stop(color: Color(red: 0.96, green: 0.73, blue: 0.92), location: 0.24),
                Gradient.Stop(color: Color(red: 0.55, green: 0.6, blue: 1), location: 0.35),
                Gradient.Stop(color: Color(red: 0.67, green: 0.43, blue: 0.93), location: 0.58),
                Gradient.Stop(color: Color(red: 1, green: 0.4, blue: 0.47), location: 0.70),
                Gradient.Stop(color: Color(red: 1, green: 0.73, blue: 0.44), location: 0.81),
                Gradient.Stop(color: Color(red: 0.78, green: 0.53, blue: 1), location: 0.92),
            ],
            center: UnitPoint(x: 0.5, y: 0.5),
            angle: angle
        )
    }

    private func animateGradient() {
        withAnimation(.easeInOut(duration: 2)) {
            let previousAngle = angle
            angle = previousAngle + Angle(degrees: 180)
        }
    }
}

#Preview {
    hForm {
        hText("TEST 2")
            .padding(30)
            .background(Color.red)
            .withGradientBorder(shape: RoundedRectangle(cornerRadius: 16, style: .continuous))
        Spacer()
    }
}

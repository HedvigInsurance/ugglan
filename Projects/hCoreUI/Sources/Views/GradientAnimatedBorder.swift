import SwiftUI

extension View {
    public func withGradientBorder<S: Shape>(shape: S) -> some View {
        self.modifier(GradientShapeBorderViewModifier(shape: shape))
    }
}

private struct GradientShapeBorderViewModifier<S: Shape>: ViewModifier {
    @State private var rotation: Double = 0
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
                GeometryReader { geo in
                    let diameter = hypot(geo.size.width, geo.size.height)
                    Circle()
                        .fill(gradient)
                        .frame(width: diameter, height: diameter)
                        .rotationEffect(.degrees(rotation))
                        .position(x: geo.size.width / 2, y: geo.size.height / 2)
                        .mask(shape.stroke(lineWidth: 2))
                }
            }
            .onAppear {
                withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
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
            angle: .degrees(0)
        )
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

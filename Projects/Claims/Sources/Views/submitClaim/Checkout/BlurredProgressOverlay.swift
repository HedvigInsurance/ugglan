import SwiftUI
import hCore
import hCoreUI

struct BlurredProgressOverlay<Content: View>: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var isAnimating = false
    var content: () -> Content

    private var largeCircleDiameter: CGFloat = 354
    private var smallCircleDiameter: CGFloat = 284

    init(
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.content = content
    }

    @hColorBuilder
    var largeCircleColor: some hColor {
        if colorScheme == .dark {
            hTintColor.yellowOne.opacity(0.25)
        } else {
            hTintColor.yellowTwo
        }
    }

    var largeCircle: some View {
        Circle()
            .foregroundColor(largeCircleColor)
            .frame(width: largeCircleDiameter, height: largeCircleDiameter)
    }

    @hColorBuilder
    var smallCircleColor: some hColor {
        if colorScheme == .dark {
            hTintColor.lavenderOne.opacity(0.25)
        } else {
            hTintColor.lavenderTwo
        }
    }

    var smallCircle: some View {
        Circle()
            .foregroundColor(smallCircleColor)
            .frame(width: smallCircleDiameter, height: smallCircleDiameter)
    }

    var body: some View {
        ZStack(alignment: .center) {
            ZStack {
                GeometryReader { geo in
                    smallCircle
                        .offset(x: geo.size.width - 150, y: isAnimating ? geo.size.height - smallCircleDiameter : 0)
                        .rotationEffect(Angle(degrees: isAnimating ? 25 : -25), anchor: .top)
                        .blur(radius: 50)

                    largeCircle
                        .offset(x: -109, y: isAnimating ? 0 : geo.size.height - largeCircleDiameter)
                        .rotationEffect(Angle(degrees: isAnimating ? -25 : 25), anchor: .top)
                        .blur(radius: 100)
                }
                .animation(isAnimating ? .easeInOut(duration: 6).repeatForever(autoreverses: true) : .none)
                .id(colorScheme)
            }
            .ignoresSafeArea()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            ZStack(alignment: .center) {
                content()
                    .padding(.horizontal, 24)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                withAnimation {
                    isAnimating = true
                }
            }
            .onChange(of: colorScheme) { newValue in
                withAnimation {
                    isAnimating = false
                }

                Task {
                    await delay(0.25)
                    withAnimation {
                        isAnimating = true
                    }
                }
            }
        }
    }

}

struct BlurredProgressOverlayPreviews: PreviewProvider {
    static var previews: some View {
        BlurredProgressOverlay {
            Text("hello world")
        }
    }
}

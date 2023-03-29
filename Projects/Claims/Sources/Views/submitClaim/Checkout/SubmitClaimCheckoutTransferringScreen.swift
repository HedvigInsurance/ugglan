import SwiftUI
import hCore
import hCoreUI

public struct SubmitClaimCheckoutTransferringScreen: View {
    @PresentableStore var store: ClaimsStore
    @State var hasActionCompleted: Bool = false

    public init() {}

    public var body: some View {

        BlurredProgressOverlay {
            ZStack(alignment: .center) {
                VStack {
                    Spacer()
                        .scaleEffect(
                            x: hasActionCompleted ? 2 : 1,
                            y: hasActionCompleted ? 2 : 1,
                            anchor: .center
                        )
                    Spacer()
                }
                .opacity(hasActionCompleted ? 0 : 1)
                .animation(.spring(), value: hasActionCompleted)

                VStack {
                    Spacer()

                    VStack(spacing: 16) {

                        hText(L10n.Claims.Payout.Progress.title, style: .title2)

                    }
                    .frame(maxHeight: .infinity, alignment: .top)
                    .scaleEffect(
                        x: hasActionCompleted ? 1 : 0.3,
                        y: hasActionCompleted ? 1 : 0.3,
                        anchor: .top
                    )

                    Spacer()
                }
                .opacity(hasActionCompleted ? 1 : 0)
                .disabled(!hasActionCompleted)
                .animation(
                    .interpolatingSpring(
                        stiffness: 170,
                        damping: 15
                    )
                    .delay(0.25),
                    value: hasActionCompleted
                )
            }
        }
        .onAppear {
            if !hasActionCompleted {
                Task {
                    await delay(2)
                    withAnimation {
                        hasActionCompleted = true
                    }
                    await delay(2)
                    store.send(.claimNextSingleItemCheckout)
                }
            }
        }
    }
}

struct SubmitClaimCheckoutTransferringScreen_Previews: PreviewProvider {
    static var previews: some View {
        SubmitClaimCheckoutTransferringScreen()
    }
}

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

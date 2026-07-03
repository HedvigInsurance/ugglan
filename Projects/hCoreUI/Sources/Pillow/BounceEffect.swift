import SwiftUI

extension View {
    /// Loops a damped-spring squash-and-stretch bounce on the view, rendered
    /// by the `pillowBounce` distortion shader: one spring bounce, a 2 second
    /// rest, then again — for as long as `isActive` is true.
    ///
    /// No-op below iOS 17 and under Reduce Motion.
    @ViewBuilder
    public func bounceEffect(_ isActive: Bool = true) -> some View {
        if #available(iOS 17.0, *) {
            modifier(BounceEffectModifier(isActive: isActive))
        } else {
            self
        }
    }
}

@available(iOS 17.0, *)
private struct BounceEffectModifier: ViewModifier {
    let isActive: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var size: CGSize = .zero
    @State private var startDate = Date()

    /// Peak squash/stretch as a fraction of the view's size.
    private static let amplitude = 0.16
    /// Damped-spring shape: decay rate and oscillation frequency (Hz).
    private static let springDecay = 4.0
    private static let springFrequency = 2.0
    /// How long one spring takes to settle. Ends on a lobe boundary of
    /// `springFrequency` so the curve reaches zero cleanly.
    private static let bounceDuration = 1.5
    /// Rest between bounces.
    private static let restDuration = 2.0
    private static let cycleDuration = bounceDuration + restDuration

    private var isBouncing: Bool { isActive && !reduceMotion }

    func body(content: Content) -> some View {
        TimelineView(.animation(minimumInterval: nil, paused: !isBouncing)) { context in
            let amount = isBouncing ? Self.amount(at: context.date.timeIntervalSince(startDate)) : 0
            content
                .distortionEffect(
                    ShaderLibrary.bundle(.hCoreUIPillow)
                        .pillowBounce(
                            .float2(size),
                            .float(Float(amount))
                        ),
                    maxSampleOffset: CGSize(
                        width: size.width * Self.amplitude,
                        height: size.height * Self.amplitude
                    ),
                    isEnabled: amount != 0
                )
        }
        .background(
            GeometryReader { geo in
                Color.clear
                    .onAppear { size = geo.size }
                    .onChange(of: geo.size) { _, newSize in size = newSize }
            }
        )
        .onChange(of: isBouncing) { _, active in
            if active { startDate = Date() }
        }
    }

    /// Damped spring `A·e^(−λt)·sin(ωt)` over the bounce window, flat through
    /// the rest window; the whole cycle repeats.
    private static func amount(at elapsed: TimeInterval) -> Double {
        guard elapsed > 0 else { return 0 }
        let t = elapsed.truncatingRemainder(dividingBy: cycleDuration)
        guard t < bounceDuration else { return 0 }
        // Negated so the spring leads with a squash (anticipation) and
        // rebounds into the stretch.
        return -amplitude * exp(-springDecay * t) * sin(2 * .pi * springFrequency * t)
    }
}

#if DEBUG
    #Preview("Bounce") {
        PillowView(.car)
            .frame(width: 240, height: 240)
            .bounceEffect()
            .padding()
    }
#endif

import SwiftUI

@available(iOS 17.0, *)
@MainActor
struct PillowMeshView: View, @MainActor Animatable {
    var configuration: PillowConfiguration

    var animatableData: AnimatableVector {
        get { configuration.animatableVector }
        set { configuration.apply(newValue) }
    }

    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            TimelineView(.animation(minimumInterval: nil, paused: configuration.speed == 0)) { context in
                let phase = configuration.speed * 0.2 * context.date.timeIntervalSinceReferenceDate
                Rectangle()
                    .fill(.black)
                    .colorEffect(shader(size: size, phase: phase))
            }
        }
    }

    private func shader(size: CGSize, phase: Double) -> Shader {
        let colors = configuration.colorComponents()
        let points = configuration.pointComponents()
        // The wave shifts feed `cos(2π · shift + …)` (period 1) and the phase is
        // driven from absolute time, so it grows huge. Reduce mod 1.0 in Double
        // BEFORE the Float cast — otherwise Float precision loss at ~1e8 freezes
        // the per-frame increment (~0.005) and the animation stalls.
        let waveXShift = (configuration.waveXShift + phase).truncatingRemainder(dividingBy: 1.0)
        let waveYShift = (configuration.waveYShift + phase * 0.7).truncatingRemainder(dividingBy: 1.0)
        let ditherSeed = phase.truncatingRemainder(dividingBy: 1.0)
        return ShaderLibrary.bundle(.hCoreUIPillow)
            .pillowMesh(
                .float2(size),
                .floatArray(colors),
                .floatArray(points),
                .float(Float(configuration.waveX)),
                .float(Float(waveXShift)),
                .float(Float(configuration.waveY)),
                .float(Float(waveYShift)),
                .float(Float(configuration.mixing)),
                .float(Float(configuration.grainMixer)),
                .float(Float(configuration.grainOverlay)),
                .float(Float(ditherSeed)),
                .float(Float(configuration.scale)),
                .float(Float(configuration.rotation)),
                .float(Float(configuration.offsetX)),
                .float(Float(configuration.offsetY))
            )
    }
}

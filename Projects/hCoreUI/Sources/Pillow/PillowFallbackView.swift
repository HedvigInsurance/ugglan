import SwiftUI

struct PillowFallbackView: View {
    var configuration: PillowConfiguration

    var body: some View {
        GeometryReader { geo in
            let diagonal = (geo.size.width * geo.size.width + geo.size.height * geo.size.height).squareRoot()
            ZStack {
                (configuration.colors.first ?? .black)

                ForEach(Array(configuration.colors.enumerated()), id: \.offset) { index, color in
                    let point = meshPoint(index)
                    RadialGradient(
                        gradient: Gradient(colors: [color, color.opacity(0)]),
                        center: UnitPoint(x: point.x, y: point.y),
                        startRadius: 0,
                        endRadius: diagonal * 0.5
                    )
                }
            }
        }
    }

    private func meshPoint(_ index: Int) -> CGPoint {
        if index < configuration.meshPoints.count {
            return configuration.meshPoints[index]
        }
        let defaults = PillowConfiguration.defaultMeshPoints(count: configuration.colors.count)
        return index < defaults.count ? defaults[index] : CGPoint(x: 0.5, y: 0.5)
    }
}

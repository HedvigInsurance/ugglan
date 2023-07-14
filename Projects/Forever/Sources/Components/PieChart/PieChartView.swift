import Foundation
import SwiftUI
import hCore
import hCoreUI

public struct PieChartView: View {
    @State var state: PieChartState
    @State var newPrice: String

    @State private var percentage: CGFloat = .zero
    @State private var nextSlicePercentage: CGFloat = .zero
    @State private var showNewAmount: Bool = false

    var animation: Animation {
        Animation.spring(response: 0.55, dampingFraction: 0.725, blendDuration: 1).delay(1)
    }

    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                Circle()
                    .foregroundColor(hSignalColorNew.greenElement)
                if !state.percentagePerSlice.isNaN && state.percentagePerSlice != 0 {
                    Slice(
                        startSlices: state.slices,
                        percentage: nextSlicePercentage,
                        percentagePerSlice: state.percentagePerSlice,
                        slices: state.slices + 1
                    )
                    .fill(hTextColorNew.tertiaryTranslucent)
                    .onAppear {
                        withAnimation(self.animation.delay(state.slices == 0 ? 0 : 1.2).repeatForever()) {
                            self.nextSlicePercentage = 1.0
                        }
                    }
                    Slice(percentage: percentage, percentagePerSlice: state.percentagePerSlice, slices: state.slices)
                        .fill(.white)
                        .onAppear {
                            withAnimation(self.animation) {
                                self.percentage = 1.0
                            }
                        }
                }

                let radAngle = Angle(degrees: -(360.0 * state.slices * state.percentagePerSlice - 90.0)).radians
                // Using cosine to make sure the label is positioned nicely around the whole circle
                let offset = abs(cos(radAngle)) * 0.16 + 1.1
                VStack {
                    if state.slices != 0 && !state.slices.isNaN && showNewAmount {
                        hText(newPrice)
                            .foregroundColor(hTextColorNew.secondary)
                            .transition(.opacity)
                    }
                }
                .position(
                    x: geometry.size.width * 0.5 * CGFloat(1.0 + offset * cos(radAngle)),
                    y: geometry.size.height * 0.5 * CGFloat(1.0 - offset * sin(radAngle))
                )
                .animation(self.animation.delay(0.2))
                .onAppear {
                    self.showNewAmount.toggle()
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

struct PieChart_Previews: PreviewProvider {
    static var previews: some View {
        PieChartView(
            state: .init(
                percentagePerSlice: 2,
                slices: 10
            ),
            newPrice: "100"
        )
    }
}

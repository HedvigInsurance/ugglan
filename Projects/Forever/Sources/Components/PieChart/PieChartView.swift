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
                    .foregroundColor(hSignalColor.Green.element)
                    .overlay(
                        Circle()
                            .stroke(hTextColor.Opaque.negative, lineWidth: 1)
                    )
                if !state.percentagePerSlice.isNaN && state.percentagePerSlice != 0 {
                    Slice(
                        startSlices: state.slices,
                        percentage: nextSlicePercentage,
                        percentagePerSlice: state.percentagePerSlice,
                        slices: state.slices + 1
                    )
                    .fill(hTextColor.Translucent.tertiary).colorScheme(.light)
                    .onAppear {
                        withAnimation(self.animation.delay(state.slices == 0 ? 0 : 1.2).repeatForever()) {
                            self.nextSlicePercentage = 1.0
                        }
                    }
                    Slice(percentage: percentage, percentagePerSlice: state.percentagePerSlice, slices: state.slices)
                        .fill(hTextColor.Opaque.negative)
                        .onAppear {
                            withAnimation(self.animation) {
                                self.percentage = 1.0
                            }
                        }
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

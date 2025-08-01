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

    public var body: some View {
        GeometryReader { _ in
            ZStack {
                Circle()
                    .foregroundColor(hSignalColor.Green.element)
                    .overlay(
                        Circle()
                            .stroke(hTextColor.Opaque.negative, lineWidth: 1)
                    )
                if !state.percentagePerSlice.isNaN, state.percentagePerSlice != 0 {
                    Slice(
                        startSlices: state.slices,
                        percentage: nextSlicePercentage,
                        percentagePerSlice: state.percentagePerSlice,
                        slices: state.slices + 1
                    )
                    .fill(hTextColor.Translucent.tertiary).colorScheme(.light)
                    .onAppear {
                        withAnimation(.defaultSpring.delay(state.slices == 0 ? 0 : 1.2).repeatForever()) {
                            nextSlicePercentage = 1.0
                        }
                    }
                    Slice(percentage: percentage, percentagePerSlice: state.percentagePerSlice, slices: state.slices)
                        .fill(hTextColor.Opaque.negative)
                        .onAppear {
                            withAnimation(.defaultSpring) {
                                percentage = 1.0
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

import Foundation
import SwiftUI
import hGraphQL

public struct PieChartState {
    public let percentagePerSlice: CGFloat
    public let slices: CGFloat

    public init(
        percentagePerSlice: CGFloat,
        slices: CGFloat
    ) {
        self.percentagePerSlice = percentagePerSlice
        self.slices = slices
    }

    public init(
        grossAmount: MonetaryAmount,
        netAmount: MonetaryAmount,
        potentialDiscountAmount: MonetaryAmount
    ) {
        let totalNeededSlices = grossAmount.value / potentialDiscountAmount.value
        slices = (CGFloat(grossAmount.value - netAmount.value) / CGFloat(potentialDiscountAmount.value))
        if grossAmount == netAmount {
            percentagePerSlice = 0.1
        } else {
            percentagePerSlice = 1 / CGFloat(totalNeededSlices)
        }
    }
}

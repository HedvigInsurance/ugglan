import Foundation
import SwiftUI
import hCore

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
        monthlyDiscountPerReferral: MonetaryAmount
    ) {
        let totalNeededSlices = grossAmount.value / monthlyDiscountPerReferral.value
        slices = (CGFloat(grossAmount.value - netAmount.value) / CGFloat(monthlyDiscountPerReferral.value))
        if grossAmount == netAmount {
            percentagePerSlice = 0.1
        } else {
            percentagePerSlice = 1 / CGFloat(totalNeededSlices)
        }
    }
}

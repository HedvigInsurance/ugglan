import Foundation
import SwiftUI
import hCore
import hCoreUI

struct HeaderView: View {
    @StateObject var vm: HeaderViewModel
    let didPressInfo: () -> Void

    init(
        foreverNavigationVm: ForeverNavigationViewModel,
        didPressInfo: @escaping () -> Void
    ) {
        _vm = StateObject(wrappedValue: .init(foreverData: foreverNavigationVm.foreverData))
        self.didPressInfo = didPressInfo
    }

    var body: some View {
        hSection {
            VStack(spacing: .padding16) {
                if let foreverData = vm.foreverData {
                    if vm.showMonthlyDiscount {
                        hText(foreverData.monthlyDiscount.negative.formattedAmount)
                            .foregroundColor(hTextColor.Opaque.secondary)
                            .accessibilityLabel(
                                L10n.foreverTabMonthlyDiscount + foreverData.monthlyDiscount.negative.formattedAmount
                            )
                    }
                    if vm.showPieChart {
                        PieChartView(
                            state: .init(
                                grossAmount: foreverData.grossAmount,
                                netAmount: foreverData.netAmount,
                                monthlyDiscountPerReferral: foreverData.monthlyDiscountPerReferral
                            ),
                            newPrice: foreverData.netAmount.formattedAmount
                        )
                        .frame(width: 215, height: 215, alignment: .center)

                        if foreverData.monthlyDiscount.value > 0 {
                            // Discount present
                            PriceSectionView(monthlyDiscount: foreverData.monthlyDiscount, didPressInfo: didPressInfo)
                                .padding(.bottom, 65)
                                .padding(.top, .padding8)
                        } else {
                            // No discount present
                            hText(
                                L10n.ReferralsEmpty.body(
                                    foreverData.monthlyDiscountPerReferral.formattedAmount
                                )
                            )
                            .foregroundColor(hTextColor.Opaque.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.center)
                            .padding(.top, .padding8)
                        }
                    }
                }
            }
            .padding(.top, .padding64)
        }
        .sectionContainerStyle(.transparent)
        .accessibilityElement(children: .combine)
    }
}

class HeaderViewModel: ObservableObject {
    @Published var showPieChart: Bool = false
    let foreverData: ForeverData?
    @Published var showMonthlyDiscount: Bool = false

    init(
        foreverData: ForeverData?
    ) {
        self.foreverData = foreverData
        setShowPieShart()
        setShowMonthlyDiscount()
    }

    private func setShowPieShart() {
        if foreverData?.grossAmount != nil,
            foreverData?.netAmount != nil,
            foreverData?.monthlyDiscountPerReferral != nil,
            foreverData?.monthlyDiscount != nil
        {
            showPieChart = true
        }
    }

    private func setShowMonthlyDiscount() {
        if let monthlyDiscount = foreverData?.monthlyDiscount, monthlyDiscount.value == 0 {
            showMonthlyDiscount = true
        }
    }
}

#Preview("HeaderView1") {
    HeaderView(foreverNavigationVm: ForeverNavigationViewModel()) {}
        .onAppear {
            Dependencies.shared.add(module: Module { () -> ForeverClient in ForeverClientDemo() })
        }
}

#Preview("HeaderView2") {
    Localization.Locale.currentLocale.send(.en_SE)
    return HeaderView(foreverNavigationVm: ForeverNavigationViewModel()) {}
}

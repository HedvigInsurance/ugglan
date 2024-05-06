import Apollo
import Foundation
import Presentation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

public struct PaymentHistoryView: View {
    @ObservedObject var vm: PaymentsHistoryViewModel
    @EnvironmentObject var router: Router

    public var body: some View {
        LoadingViewWithContent(
            PaymentStore.self,
            [.getHistory],
            [.getHistory]
        ) {
            PresentableStoreLens(
                PaymentStore.self,
                getter: { state in
                    state.paymentHistory
                }
            ) { history in
                if history.isEmpty {
                    VStack(spacing: 16) {
                        Image(uiImage: hCoreUIAssets.infoIconFilled.image)
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(hSignalColor.blueElement)
                        hText(L10n.paymentsNoHistoryData)
                            .multilineTextAlignment(.center)
                    }
                } else {
                    hForm {
                        VStack(spacing: 16) {
                            ForEach(history) { item in
                                hSection(item.valuesPerMonth) { month in
                                    hRow {
                                        HStack(
                                            alignment: month.paymentData.status.hasFailed ? .top : .center,
                                            spacing: 0
                                        ) {
                                            VStack(alignment: .leading, spacing: 0) {
                                                hText(month.paymentData.payment.date.displayDateShort)
                                                if month.paymentData.status.hasFailed {
                                                    hText(L10n.paymentsOutstandingPayment, style: .standardSmall)
                                                }
                                            }
                                            Spacer()
                                            hText(month.paymentData.payment.net.formattedAmount)
                                        }
                                    }
                                    .withCustomAccessory {
                                        VStack(spacing: 0) {
                                            if month.paymentData.status.hasFailed {
                                                Spacing(height: 4)
                                                    .fixedSize()

                                            }
                                            Image(uiImage: hCoreUIAssets.chevronRightSmall.image)
                                                .foregroundColor(hTextColor.secondary)
                                            if month.paymentData.status.hasFailed {
                                                Spacer()
                                            }
                                        }
                                    }
                                    .onTap {
                                        router.push(month.paymentData)
                                    }
                                    .foregroundColor(
                                        getColor(hTextColor.secondary, hasFailed: month.paymentData.status.hasFailed)
                                    )
                                    .padding(.horizontal, -16)
                                }
                                .withHeader {
                                    hText(item.year)
                                        .padding(.bottom, -16)
                                }
                            }
                            if history.flatMap({ $0.valuesPerMonth }).count >= 12 {
                                hSection {
                                    InfoCard(text: L10n.paymentsHistoryInfo, type: .info)
                                }
                            }
                        }
                        .padding(.vertical, 16)
                    }
                    .sectionContainerStyle(.transparent)
                }
            }
            .presentableStoreLensAnimation(.default)
        }
    }

    @hColorBuilder
    private func getColor(_ baseColor: some hColor, hasFailed: Bool) -> some hColor {
        if hasFailed {
            hSignalColor.redElement
        } else {
            baseColor
        }
    }
}

class PaymentsHistoryViewModel: ObservableObject {
    @Inject private var paymentService: hPaymentService

    init() {
        let store: PaymentStore = globalPresentableStoreContainer.get()
        store.send(.getHistory)
    }
}

struct PaymentHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        Localization.Locale.currentLocale = .sv_SE
        Dependencies.shared.add(module: Module { () -> hPaymentService in hPaymentServiceDemo() })
        return PaymentHistoryView(vm: .init())
    }
}

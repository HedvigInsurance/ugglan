import Apollo
import Flow
import Form
import Foundation
import Presentation
import SwiftUI
import UIKit
import hCore
import hCoreUI
import hGraphQL

public struct PaymentHistoryView: View {
    @PresentableStore var store: PaymentStore
    @ObservedObject var vm: PaymentsHistoryViewModel
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
                hForm {
                    ForEach(history) { item in
                        hSection(item.valuesPerMonth) { month in
                            hRow {
                                HStack {
                                    hText(month.date.displayDateShort)
                                    Spacer()
                                    hText(month.amount.formattedAmount)
                                }
                            }
                            .noHorizontalPadding()
                            .withChevronAccessory
                            .onTap {
                                store.send(.navigation(to: .openPaymentDetails(data: month.paymentData)))
                            }
                            .foregroundColor(
                                getColor(hTextColor.secondary, hasFailed: month.paymentData.status.hasFailed)
                            )
                            .padding(.horizontal, -16)

                        }
                        .withHeader {
                            hText(item.year)
                        }
                    }
                    .padding(.vertical, 16)
                }
                .sectionContainerStyle(.transparent)
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

extension PaymentHistoryView {
    public static var journey: some JourneyPresentation {
        return HostingJourney(
            PaymentStore.self,
            rootView: PaymentHistoryView(vm: .init())
        ) { action in
            if case let .navigation(navigateTo) = action {
                if case .goBack = navigateTo {
                    PopJourney()
                } else if case let .openPaymentDetails(data) = navigateTo {
                    PaymentDetails.journey(with: data)
                }
            }
        }
        .configureTitle(L10n.paymentHistoryTitle)
    }
}

struct PaymentHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        Localization.Locale.currentLocale = .sv_SE
        Dependencies.shared.add(module: Module { () -> hPaymentService in hPaymentServiceDemo() })
        return PaymentHistoryView(vm: .init())
    }
}

import AppStateContainer
import Combine
import Foundation
import SwiftUI
import hCore
import hCoreUI

public struct PaymentHistoryView: View {
    @EnvironmentObject var router: NavigationRouter
    @AppObservedObject var store: PaymentStore
    @StateObject var vm = PaymentsHistoryViewModel()

    public var body: some View {
        successView.loading($vm.viewState)
            .hStateViewButtonConfig(
                .init(
                    actionButton: .init(buttonAction: {
                        Task { await store.getHistory() }
                    }),
                    dismissButton: nil
                )
            )
            .task {
                await store.getHistory()
            }
    }

    private var successView: some View {
        let history = store.paymentHistory
        return Group {
            if history.isEmpty {
                VStack(spacing: .padding16) {
                    hCoreUIAssets.infoFilled.view
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(hSignalColor.Blue.element)
                    hText(L10n.paymentsNoHistoryData)
                        .multilineTextAlignment(.center)
                }
            } else {
                hForm {
                    VStack(spacing: .padding16) {
                        ForEach(history) { item in
                            hSection(item.valuesPerMonth) { month in
                                hRow {
                                    HStack(
                                        alignment: month.paymentData.status.hasFailed ? .top : .center,
                                        spacing: 0
                                    ) {
                                        VStack(
                                            alignment: .leading,
                                            spacing: 0
                                        ) {
                                            hText(month.paymentData.payment.date.displayDateShort)
                                            if month.paymentData.status.hasFailed {
                                                hText(L10n.paymentsOutstandingPayment, style: .label)
                                            }
                                        }
                                        Spacer()
                                        hText(month.paymentData.payment.net.formattedAmount)
                                        hText(" ")
                                    }
                                }
                                .withCustomAccessory {
                                    VStack(spacing: 0) {
                                        if month.paymentData.status.hasFailed {
                                            Spacing(height: 4)
                                                .fixedSize()
                                        }
                                        hCoreUIAssets.chevronRightSmall.view
                                            .foregroundColor(hTextColor.Opaque.secondary)
                                        if month.paymentData.status.hasFailed {
                                            Spacer()
                                        }
                                    }
                                }
                                .onTap {
                                    router.push(month.paymentData)
                                }
                                .foregroundColor(
                                    getColor(
                                        hTextColor.Opaque.secondary,
                                        hasFailed: month.paymentData.status.hasFailed
                                    )
                                )
                                .padding(.horizontal, -16)
                                .accessibilityElement(children: .combine)
                            }
                            .withHeader(title: String(item.year), withoutBottomPadding: true)
                        }
                        if history.flatMap(\.valuesPerMonth).count >= 12 {
                            hSection {
                                InfoCard(text: L10n.paymentsHistoryInfo, type: .info)
                            }
                        }
                    }
                    .padding(.vertical, .padding16)
                }
                .hSetScrollBounce(to: true)
                .sectionContainerStyle(.transparent)
                .onPullToRefresh {
                    await store.getHistory()
                }
            }
        }
        .animation(.default, value: history)
    }

    @hColorBuilder
    private func getColor(_ baseColor: some hColor, hasFailed: Bool) -> some hColor {
        if hasFailed {
            hSignalColor.Red.element
        } else {
            baseColor
        }
    }
}

@MainActor
public class PaymentsHistoryViewModel: ObservableObject {
    @Published var viewState: ProcessingState = .loading
    @AppState private var store: PaymentStore
    private var cancellables = Set<AnyCancellable>()

    init() {
        store.$isLoadingHistory
            .combineLatest(store.$loadHistoryError)
            .receive(on: RunLoop.main)
            .sink { [weak self] isLoading, error in
                if isLoading {
                    self?.viewState = .loading
                } else if let error {
                    self?.viewState = .error(errorMessage: error)
                } else {
                    self?.viewState = .success
                }
            }
            .store(in: &cancellables)
    }
}

#Preview {
    Localization.Locale.currentLocale.send(.sv_SE)
    Dependencies.shared.add(module: Module { () -> hPaymentClient in hPaymentClientDemo() })
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    return PaymentHistoryView()
}

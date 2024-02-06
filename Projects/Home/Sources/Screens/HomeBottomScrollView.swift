import Apollo
import Combine
import Contracts
import EditCoInsured
import Flow
import Payment
import Presentation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct HomeBottomScrollView: View {
    @ObservedObject private var vm: HomeButtonScrollViewModel
    @StateObject var scrollVM: InfoCardScrollViewModel
    init(memberId: String) {
        self.vm = HomeButtonScrollViewModel(memberId: memberId)
        self._scrollVM = StateObject(wrappedValue: .init(spacing: 16, zoomFactor: 0.9, itemsCount: 0))
    }

    var body: some View {
        InfoCardScrollView(
            items: vm.items.sorted(by: { $0.id < $1.id }),
            vm: scrollVM,
            content: { content in
                switch content.id {
                case .payment:
                    ConnectPaymentCardView()
                case .renewal:
                    RenewalCardView()
                case .deletedView:
                    InfoCard(
                        text: L10n.hometabAccountDeletionNotification,
                        type: .attention
                    )
                case let .importantMessage(id):
                    let store: HomeStore = globalPresentableStoreContainer.get()
                    if let importantMessage = store.state.getImportantMessage(with: id) {
                        ImportantMessageView(importantMessage: importantMessage)
                    }
                case .missingCoInsured:
                    CoInsuredInfoHomeView {
                        let contractStore: ContractStore = globalPresentableStoreContainer.get()
                        let contractIds: [InsuredPeopleConfig] = contractStore.state.activeContracts
                            .filter({
                                $0.nbOfMissingCoInsuredWithoutTermination > 0 && $0.showEditCoInsuredInfo
                            }
                            )
                            .compactMap {
                                InsuredPeopleConfig(
                                    contract: $0
                                )
                            }
                        let homeStore: HomeStore = globalPresentableStoreContainer.get()
                        homeStore.send(.openCoInsured(contractIds: contractIds))
                    }
                }
            }
        )
        .onChange(of: vm.items) { value in
            scrollVM.updateItems(count: value.count)
        }
    }
}

class HomeButtonScrollViewModel: ObservableObject {
    @Published var items = Set<InfoCardView>()
    private var showConnectPaymentCardView = false
    var cancellables = Set<AnyCancellable>()
    init(memberId: String) {
        handlePayments()
        if Dependencies.featureFlags().isEditCoInsuredEnabled {
            handleMissingCoInsured()
        }
        handleImportantMessages()
        handleRenewalCardView()
        handleDeleteRequests(memberId: memberId)
    }

    private func handleItem(_ item: InfoCardType, with addItem: Bool) {
        let item = InfoCardView(with: item)
        if addItem {
            _ = withAnimation {
                self.items.insert(item)
            }
        } else {
            _ = withAnimation {
                self.items.remove(item)
            }
        }
    }

    private func handlePayments() {
        let paymentStore: PaymentStore = globalPresentableStoreContainer.get()

        paymentStore.stateSignal.plain()
            .map({ $0.paymentStatusData?.status == .needsSetup })
            .distinct()
            .publisher
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] needSetup in
                self?.handleItem(.payment, with: needSetup)
            })
            .store(in: &cancellables)
        handleItem(.payment, with: paymentStore.state.paymentStatusData?.status == .needsSetup)
        paymentStore.send(.fetchPaymentStatus)
    }

    private func handleImportantMessages() {
        let homeStore: HomeStore = globalPresentableStoreContainer.get()
        homeStore.stateSignal.plain()
            .map({ $0.getImportantMessageToShow() })
            .distinct()
            .publisher
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] importantMessages in guard let self = self else { return }
                var oldItems = self.items
                let itemsToRemove = oldItems.filter { view in
                    switch view.id {
                    case .importantMessage:
                        return true
                    default:
                        return false
                    }
                }
                for itemToRemove in itemsToRemove {
                    oldItems.remove(itemToRemove)
                }
                for importantMessage in importantMessages {
                    oldItems.insert(.init(with: .importantMessage(message: importantMessage.id)))
                }
                withAnimation {
                    self.items = oldItems
                }
            })
            .store(in: &cancellables)
        let itemsToShow = homeStore.state.getImportantMessageToShow()
        for importantMessage in itemsToShow {
            self.handleItem(.importantMessage(message: importantMessage.id), with: true)
        }
    }

    private func handleRenewalCardView() {
        let homeStore: HomeStore = globalPresentableStoreContainer.get()
        homeStore.stateSignal.plain()
            .map({ $0.upcomingRenewalContracts.count > 0 })
            .distinct()
            .publisher
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] show in
                self?.handleItem(.renewal, with: show)
            })
            .store(in: &cancellables)
        handleItem(.renewal, with: homeStore.state.upcomingRenewalContracts.count > 0)
    }

    private func handleDeleteRequests(memberId: String) {
        let members = ApolloClient.retreiveMembersWithDeleteRequests()
        let store: ContractStore = globalPresentableStoreContainer.get()
        handleItem(
            .deletedView,
            with: members.contains(memberId)
                && (store.state.activeContracts.count == 0 && store.state.pendingContracts.count == 0)
        )

    }

    private func handleMissingCoInsured() {
        let contractStore: ContractStore = globalPresentableStoreContainer.get()
        contractStore.stateSignal.plain()
            .map({
                $0.activeContracts
                    .filter { contract in
                        if contract.coInsured.isEmpty {
                            return false
                        } else {
                            return contract.coInsured.filter({ !$0.hasMissingData && contract.terminationDate == nil })
                                .isEmpty
                        }
                    }
                    .filter({ $0.supportsCoInsured })
                    .isEmpty == false
            })
            .distinct()
            .publisher
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] show in
                self?.handleItem(.missingCoInsured, with: show)
            })
            .store(in: &cancellables)

        let show =
            contractStore.state.activeContracts
            .filter { contract in
                if contract.coInsured.isEmpty {
                    return false
                } else {
                    return contract.coInsured.filter({ !$0.hasMissingData && contract.terminationDate == nil }).isEmpty
                }
            }
            .filter({ $0.supportsCoInsured })
            .isEmpty == false
        handleItem(.missingCoInsured, with: show)
    }
}

struct HomeBottomScrollView_Previews: PreviewProvider {
    static var previews: some View {
        HomeBottomScrollView(memberId: "")
    }
}

struct InfoCardView: Identifiable, Hashable {
    let id: InfoCardType
    init(with type: InfoCardType) {
        self.id = type
    }
}

enum InfoCardType: Hashable, Comparable {
    case payment
    case missingCoInsured
    case importantMessage(message: String)
    case renewal
    case deletedView
}

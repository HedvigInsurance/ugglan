import Apollo
import Combine
import Contracts
import Flow
import Payment
import Presentation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct HomeBottomScrollView: View {
    @ObservedObject private var vm: HomeButtonScrollViewModel

    init(memberId: String) {
        self.vm = HomeButtonScrollViewModel(memberId: memberId)
    }

    var body: some View {
        return InfoCardScrollView(
            spacing: 16,
            items: vm.items.sorted(by: { $0.id < $1.id }),
            content: { content in
                switch content.type {
                case .payment:
                    ConnectPaymentCardView()
                case .renewal:
                    RenewalCardView()
                case .deletedView:
                    InfoCard(
                        text: L10n.hometabAccountDeletionNotification,
                        type: .attention
                    )
                case .importantMessage:
                    ImportantMessagesView()
                case .missingCoInsured:
                    CoInsuredInfoHomeView {
                        let contractStore: ContractStore = globalPresentableStoreContainer.get()
                        let contractIds: [String] = contractStore.state.activeContracts.compactMap {
                            ($0.id)
                        }
                        let homeStore: HomeStore = globalPresentableStoreContainer.get()
                        homeStore.send(.openCoInsured(contractIds: contractIds))
                    }
                }
            }
        )
    }
}

class HomeButtonScrollViewModel: ObservableObject {
    @Published var items = Set<InfoCardView>()
    private var showConnectPaymentCardView = false
    var cancellables = Set<AnyCancellable>()
    init(memberId: String) {
        handlePayments()
        handleMissingCoInsured()
        handleImportantMessages()
        handleRenewalCardView()
        handleDeleteRequests(memberId: memberId)
    }

    private func handleItem(_ item: InfoCardType, with addItem: Bool) {
        let item = InfoCardView(with: item)
        if addItem {
            self.items.insert(item)
        } else {
            self.items.remove(item)
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
            .map({ $0.importantMessage != nil && !$0.hideImportantMessage })
            .distinct()
            .publisher
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] show in
                self?.handleItem(.importantMessage, with: show)
            })
            .store(in: &cancellables)
        handleItem(
            .importantMessage,
            with: homeStore.state.importantMessage != nil && !homeStore.state.hideImportantMessage
        )
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
        handleItem(.deletedView, with: members.contains(memberId))
    }

    private func handleMissingCoInsured() {
        let contractStore: ContractStore = globalPresentableStoreContainer.get()
        contractStore.stateSignal.plain()
            .map({ $0.activeContracts.map { $0.coInsured.contains(CoInsuredModel(name: nil, SSN: nil)) } })
            .distinct()
            .publisher
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] show in
                self?.handleItem(.missingCoInsured, with: show[1])
            })
            .store(in: &cancellables)
        let show = contractStore.state.activeContracts.contains(where: {
            $0.coInsured.contains(CoInsuredModel(name: nil, SSN: nil))
        })
        handleItem(.missingCoInsured, with: show)
    }
}

struct HomeBottomScrollView_Previews: PreviewProvider {
    static var previews: some View {
        HomeBottomScrollView(memberId: "")
    }
}

struct InfoCardView: Identifiable, Hashable {
    let id: Int
    let type: InfoCardType
    init(with type: InfoCardType) {
        self.id = type.rawValue
        self.type = type
    }
}

enum InfoCardType: Int {
    case payment
    case missingCoInsured
    case importantMessage
    case renewal
    case deletedView
}

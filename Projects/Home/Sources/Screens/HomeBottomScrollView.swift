import Apollo
import Combine
import Contracts
import EditCoInsuredShared
import Payment
import Presentation
import SwiftUI
import hCore
import hCoreUI

struct HomeBottomScrollView: View {
    @ObservedObject private var vm: HomeButtonScrollViewModel
    @StateObject var scrollVM: InfoCardScrollViewModel = .init(spacing: 16, zoomFactor: 0.9, itemsCount: 0)
    @EnvironmentObject var navigationVm: HomeNavigationViewModel

    init(memberId: String) {
        self.vm = HomeButtonScrollViewModel(memberId: memberId)
    }

    var body: some View {
        InfoCardScrollView(
            items: vm.items.sorted(by: { $0.id < $1.id }),
            vm: scrollVM,
            content: { content in
                switch content.id {
                case .payment:
                    ConnectPaymentCardView()
                        .environmentObject(navigationVm.connectPaymentVm)
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
                        navigationVm.editCoInsuredVm.start(forMissingCoInsured: true)
                    }
                case .terminated:
                    InfoCard(text: L10n.HomeTab.terminatedBody, type: .info)
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
        handleTerminatedMessage()
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
        let homeStore: HomeStore = globalPresentableStoreContainer.get()
        homeStore.stateSignal
            .map({ $0.memberContractState })
            .plain()
            .publisher.receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] memberContractState in
                switch memberContractState {
                case .terminated:
                    self?.handleItem(.terminated, with: true)
                default:
                    self?.handleItem(.terminated, with: false)
                }
            })
            .store(in: &cancellables)
        switch homeStore.state.memberContractState {
        case .active, .future:
            handleItem(.terminated, with: true)
        default:
            handleItem(.terminated, with: false)
        }
        let needsPaymentSetupPublisher = paymentStore.stateSignal.plain()
            .map({ $0.paymentStatusData?.status })
            .distinct()
            .publisher
        let memberStatePublisher = homeStore.stateSignal.plain()
            .map({ $0.memberContractState })
            .distinct()
            .publisher

        Publishers.CombineLatest(needsPaymentSetupPublisher, memberStatePublisher)
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] (paymentStatus, memberState) in
                self?.setConnectPayments(for: memberState, status: paymentStatus)
            })
            .store(in: &cancellables)
        setConnectPayments(
            for: homeStore.state.memberContractState,
            status: paymentStore.state.paymentStatusData?.status
        )
        paymentStore.send(.fetchPaymentStatus)
    }

    private func setConnectPayments(for userStatus: MemberContractState?, status: PayinMethodStatus?) {
        handleItem(
            .payment,
            with: status?.showConnectPayment ?? false
                && [MemberContractState.active, MemberContractState.future].contains(userStatus)
        )
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
                $0.activeContracts.hasMissingCoInsured
            })
            .distinct()
            .publisher
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] show in
                self?.handleItem(.missingCoInsured, with: show)
            })
            .store(in: &cancellables)

        let show = contractStore.state.activeContracts.hasMissingCoInsured
        handleItem(.missingCoInsured, with: show)
    }

    func handleTerminatedMessage() {
        let store: HomeStore = globalPresentableStoreContainer.get()
        store.stateSignal
            .map({ $0.memberContractState })
            .plain()
            .publisher.receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] memberContractState in
                switch memberContractState {
                case .terminated:
                    self?.handleItem(.terminated, with: true)
                default:
                    self?.handleItem(.terminated, with: false)
                }
            })
            .store(in: &cancellables)
        switch store.state.memberContractState {
        case .terminated:
            handleItem(.terminated, with: true)
        default:
            handleItem(.terminated, with: false)
        }
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
    case terminated
}

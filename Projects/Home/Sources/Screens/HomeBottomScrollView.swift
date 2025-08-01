import Apollo
import Combine
import Contracts
import EditCoInsured
import hCore
import hCoreUI
import Payment
import PresentableStore
import SwiftUI

struct HomeBottomScrollView: View {
    @ObservedObject private var vm: HomeBottomScrollViewModel
    @StateObject var scrollVM: InfoCardScrollViewModel = .init(spacing: 16)
    @EnvironmentObject var navigationVm: HomeNavigationViewModel

    init(vm: HomeBottomScrollViewModel) {
        self.vm = vm
    }

    var body: some View {
        InfoCardScrollView(
            items: $vm.items,
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
                case .updateContactInfo:
                    ContactInfoView()
                }
            }
        )
    }
}

@MainActor
class HomeBottomScrollViewModel: ObservableObject {
    @Published var items = [InfoCardView]()
    private var localItems = Set<InfoCardView>() {
        didSet {
            withAnimation {
                items = localItems.sorted(by: { $0.id < $1.id })
            }
        }
    }

    private var showConnectPaymentCardView = false
    var cancellables = Set<AnyCancellable>()

    init() {
        handlePayments()
        handleMissingCoInsured()
        handleImportantMessages()
        handleRenewalCardView()
        handleTerminatedMessage()
        handleUpdateOfMemberId()
        handleUpdateContactInfo()
    }

    private func handleItem(_ item: InfoCardType, with addItem: Bool) {
        let item = InfoCardView(with: item)
        if addItem {
            _ = withAnimation {
                self.localItems.insert(item)
            }
        } else {
            _ = withAnimation {
                self.localItems.remove(item)
            }
        }
    }

    private func handlePayments() {
        let paymentStore: PaymentStore = globalPresentableStoreContainer.get()
        let homeStore: HomeStore = globalPresentableStoreContainer.get()
        homeStore.stateSignal
            .map(\.memberContractState)
            .prepend()
            .receive(on: RunLoop.main)
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
        case .terminated:
            handleItem(.terminated, with: true)
        default:
            handleItem(.terminated, with: false)
        }
        let needsPaymentSetupPublisher = paymentStore.stateSignal
            .map { $0.paymentStatusData?.status }
            .removeDuplicates()
            .prepend()
        let memberStatePublisher = homeStore.stateSignal
            .map(\.memberContractState)
            .removeDuplicates()
            .prepend()

        Publishers.CombineLatest(needsPaymentSetupPublisher, memberStatePublisher)
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] paymentStatus, memberState in
                self?.setConnectPayments(for: memberState, status: paymentStatus)
            })
            .store(in: &cancellables)

        setConnectPayments(
            for: homeStore.state.memberContractState,
            status: paymentStore.state.paymentStatusData?.status
        )
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
        homeStore.stateSignal
            .map { $0.getImportantMessageToShow() }
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] importantMessages in
                guard let self = self else { return }
                var oldItems = self.localItems
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
                    self.localItems = oldItems
                }
            })
            .store(in: &cancellables)
        let itemsToShow = homeStore.state.getImportantMessageToShow()
        for importantMessage in itemsToShow {
            handleItem(.importantMessage(message: importantMessage.id), with: true)
        }
    }

    private func handleRenewalCardView() {
        let homeStore: HomeStore = globalPresentableStoreContainer.get()
        homeStore.stateSignal
            .map { $0.upcomingRenewalContracts.count > 0 }
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] show in
                self?.handleItem(.renewal, with: show)
            })
            .store(in: &cancellables)
        handleItem(.renewal, with: homeStore.state.upcomingRenewalContracts.count > 0)
    }

    private func handleUpdateOfMemberId() {
        let store: HomeStore = globalPresentableStoreContainer.get()
        store.stateSignal
            .compactMap { $0.memberInfo?.id }
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { memberId in
                self.handleDeleteRequests(memberId: memberId)
            }
            .store(in: &cancellables)
    }

    private func handleDeleteRequests(memberId: String) {
        Task {
            let members = ApolloClient.retreiveMembersWithDeleteRequests()
            let store: ContractStore = globalPresentableStoreContainer.get()
            handleItem(
                .deletedView,
                with: members.contains(memberId)
                    && (store.state.activeContracts.count == 0 && store.state.pendingContracts.count == 0)
            )
        }
    }

    private func handleMissingCoInsured() {
        let contractStore: ContractStore = globalPresentableStoreContainer.get()
        contractStore.stateSignal
            .map(\.activeContracts.hasMissingCoInsured)
            .removeDuplicates()
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
            .map(\.memberContractState)
            .receive(on: RunLoop.main)
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

    func handleUpdateContactInfo() {
        let store: HomeStore = globalPresentableStoreContainer.get()
        store.stateSignal
            .compactMap { $0.memberInfo?.isContactInfoUpdateNeeded }
            .sink(receiveValue: { [weak self] isContactInfoUpdateNeeded in
                self?.handleItem(.updateContactInfo, with: isContactInfoUpdateNeeded)
            })
            .store(in: &cancellables)

        let isContactInfoUpdateNeeded = store.state.memberInfo?.isContactInfoUpdateNeeded ?? false
        handleItem(.updateContactInfo, with: isContactInfoUpdateNeeded)
    }
}

struct HomeBottomScrollView_Previews: PreviewProvider {
    static var previews: some View {
        Dependencies.shared.add(module: Module { () -> FeatureFlagsClient in FeatureFlagsDemo() })
        return HomeBottomScrollView(vm: .init())
    }
}

struct InfoCardView: Identifiable, Hashable {
    let id: InfoCardType
    init(with type: InfoCardType) {
        id = type
    }
}

enum InfoCardType: Hashable, Comparable {
    case payment
    case missingCoInsured
    case importantMessage(message: String)
    case renewal
    case deletedView
    case terminated
    case updateContactInfo
}

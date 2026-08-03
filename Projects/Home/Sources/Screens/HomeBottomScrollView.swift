import AppStateContainer
import Combine
import Contracts
import Payment
import SwiftUI
import hCore
import hCoreUI

struct HomeBottomScrollView: View {
    @StateObject private var vm: HomeBottomScrollViewModel
    @StateObject var scrollVM: InfoCardScrollViewModel = .init(spacing: 16)

    init(vm: HomeBottomScrollViewModel? = nil) {
        _vm = StateObject(wrappedValue: vm ?? HomeBottomScrollViewModel())
    }

    var body: some View {
        InfoCardScrollView(
            items: $vm.items,
            vm: scrollVM,
            content: { content in
                switch content.id {
                case .renewal: RenewalCardView()
                case let .importantMessage(id):
                    let store: HomeStore = globalAppStateContainer.get()
                    if let importantMessage = store.getImportantMessage(with: id) {
                        ImportantMessageView(importantMessage: importantMessage)
                    }
                case .terminated: InfoCard(text: L10n.HomeTab.terminatedBody, type: .info)
                }
            }
        )
    }
}

@MainActor
class HomeBottomScrollViewModel: ObservableObject {
    @Published var items = [InfoCardView]()
    @Published var todos = [Todo]()
    private let contractStore: ContractStore = globalAppStateContainer.get()

    private var localItems = Set<InfoCardView>() {
        didSet {
            withAnimation { items = localItems.sorted(by: { $0.id < $1.id }) }
        }
    }

    private var localTodos = Set<Todo>() {
        didSet {
            withAnimation { todos = localTodos.sorted() }
        }
    }

    var cancellables = Set<AnyCancellable>()

    init() {
        handlePayments()
        handleMissingCoInsured()
        handleMissingCoOwners()
        handleImportantMessages()
        handleRenewalCardView()
        handleTerminatedMessage()
        handleUpdateContactInfo()
        handleMissingPetChipIds()
    }

    private func handleItem(_ item: InfoCardType, with addItem: Bool) {
        let item = InfoCardView(with: item)
        withAnimation {
            if addItem { localItems.insert(item) } else { localItems.remove(item) }
        }
    }

    private func handleTodo(_ todo: Todo, with addItem: Bool) {
        withAnimation {
            if addItem { localTodos.insert(todo) } else { localTodos.remove(todo) }
        }
    }

    private func handlePayments() {
        let paymentStore: PaymentStore = globalAppStateContainer.get()
        let homeStore: HomeStore = globalAppStateContainer.get()
        let needsPaymentSetupPublisher = paymentStore.$paymentStatusData
            .removeDuplicates()
        let memberStatePublisher = homeStore.$memberContractState
            .removeDuplicates()

        Publishers.CombineLatest(needsPaymentSetupPublisher, memberStatePublisher)
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] paymentStatus, memberState in
                self?.setConnectPayments(for: memberState, status: paymentStatus)
            })
            .store(in: &cancellables)
    }

    private func setConnectPayments(for userStatus: MemberContractState?, status: PaymentStatusData?) {
        let missingPayin = status?.missingConnection == .payin
        let missingPayout = status?.missingConnection == .payout
        let showsPayin = missingPayin && [MemberContractState.active, MemberContractState.future].contains(userStatus)
        let isTerminatingDueToMissedPayments =
            if case .terminatingDueToMissedPayments = status?.status { true } else { false }
        let showsPayout = missingPayout && !missingPayin

        handleTodo(.paymentOverdue, with: isTerminatingDueToMissedPayments)
        handleTodo(.paymentMethodMissing, with: showsPayin && !isTerminatingDueToMissedPayments)
        handleTodo(.payoutMethodMissing, with: showsPayout)
    }

    private func handleImportantMessages() {
        let homeStore: HomeStore = globalAppStateContainer.get()
        homeStore.$importantMessages
            .combineLatest(homeStore.$hidenImportantMessages)
            .map { importantMessages, hidenImportantMessages in
                importantMessages.filter { !hidenImportantMessages.contains($0.id) }
            }
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] importantMessages in
                guard let self = self else { return }
                var oldItems = self.localItems
                let itemsToRemove = oldItems.filter { view in
                    switch view.id {
                    case .importantMessage: true
                    default: false
                    }
                }
                for itemToRemove in itemsToRemove {
                    oldItems.remove(itemToRemove)
                }
                for importantMessage in importantMessages {
                    oldItems.insert(.init(with: .importantMessage(message: importantMessage.id)))
                }
                withAnimation { self.localItems = oldItems }
            })
            .store(in: &cancellables)
    }

    private func handleRenewalCardView() {
        let homeStore: HomeStore = globalAppStateContainer.get()
        homeStore.$contracts
            .map { $0.contains(where: { $0.upcomingRenewal != nil }) }
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] show in
                self?.handleItem(.renewal, with: show)
            })
            .store(in: &cancellables)
    }

    private func handleMissingCoInsured() {
        contractStore.$activeContracts
            .map(\.hasMissingCoInsured)
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] show in
                self?.handleTodo(.coInsuredMissing, with: show)
            })
            .store(in: &cancellables)
    }

    private func handleMissingCoOwners() {
        contractStore.$activeContracts
            .map(\.hasMissingCoOwners)
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] show in
                self?.handleTodo(.coOwnerMissing, with: show)
            })
            .store(in: &cancellables)
    }

    func handleTerminatedMessage() {
        let store: HomeStore = globalAppStateContainer.get()
        store.$memberContractState
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] memberContractState in
                switch memberContractState {
                case .terminated: self?.handleItem(.terminated, with: true)
                default: self?.handleItem(.terminated, with: false)
                }
            })
            .store(in: &cancellables)
    }

    func handleUpdateContactInfo() {
        let store: HomeStore = globalAppStateContainer.get()
        store.$memberInfo
            .compactMap { $0?.isContactInfoUpdateNeeded }
            .removeDuplicates()
            .sink(receiveValue: { [weak self] isContactInfoUpdateNeeded in
                self?.handleTodo(.contactDetailsMissing, with: isContactInfoUpdateNeeded)
            })
            .store(in: &cancellables)
    }

    private func handleMissingPetChipIds() {
        contractStore.$activeContracts
            .map { $0.contains { $0.missingPetChipId } }
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] show in
                self?.handleTodo(.petChipIdMissing, with: show)
            })
            .store(in: &cancellables)
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> FeatureFlagsClient in FeatureFlagsDemo() })
    return HomeBottomScrollView()
}

struct InfoCardView: Identifiable, Hashable {
    let id: InfoCardType
    init(with type: InfoCardType) {
        id = type
    }
}

public enum InfoCardType: Hashable, Comparable {
    case importantMessage(message: String)
    case renewal
    case terminated
}

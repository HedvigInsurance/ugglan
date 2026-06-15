import Apollo
import AppStateContainer
import Combine
import Contracts
import EditStakeholders
import Payment
import PresentableStore
import SwiftUI
import hCore
import hCoreUI

struct HomeBottomScrollView: View {
    @StateObject private var vm = HomeBottomScrollViewModel()
    @StateObject var scrollVM: InfoCardScrollViewModel = .init(spacing: 16)
    @EnvironmentObject var navigationVm: HomeNavigationViewModel

    var body: some View {
        InfoCardScrollView(
            items: $vm.items,
            vm: scrollVM,
            content: { content in
                switch content.id {
                case .payment:
                    ConnectPaymentCardView()
                        .environmentObject(navigationVm.connectPaymentVm)
                case .payout:
                    ConnectPayoutCardView { [weak navigationVm] in
                        navigationVm?.isPayoutMethodPresented = true
                    }
                case .renewal:
                    RenewalCardView()
                case let .importantMessage(id):
                    let store: HomeStore = globalAppStateContainer.get()
                    if let importantMessage = store.getImportantMessage(with: id) {
                        ImportantMessageView(importantMessage: importantMessage)
                    }
                case .missingCoInsured(let type):
                    StakeholderInfoHomeView(infoText: type.missingAddInfoText) {
                        navigationVm.editStakeholdersVm.start(stakeholderType: type, forMissingStakeholders: true)
                    }
                case .terminated:
                    InfoCard(text: L10n.HomeTab.terminatedBody, type: .info)
                case .updateContactInfo:
                    ContactInfoView()
                case .missingPetChipId:
                    MissingPetChipIdInfoCard {
                        NotificationCenter.default.post(name: .openMissingPetChipId, object: nil)
                    }
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
        let homeStore: HomeStore = globalAppStateContainer.get()
        homeStore.$memberContractState
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
        let needsPaymentSetupPublisher = paymentStore.stateSignal
            .map { $0.paymentStatusData }
            .removeDuplicates()
            .prepend()
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
        handleItem(
            .payment,
            with: missingPayin
                && [MemberContractState.active, MemberContractState.future].contains(userStatus)
        )
        handleItem(
            .payout,
            with: missingPayout && !missingPayin
        )
    }

    private func handleImportantMessages() {
        let homeStore: HomeStore = globalAppStateContainer.get()
        homeStore.$importantMessages
            .combineLatest(homeStore.$hidenImportantMessages)
            .map { _, _ in homeStore.getImportantMessageToShow() }
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
        let contractStore: ContractStore = globalAppStateContainer.get()
        contractStore.$activeContracts
            .map(\.hasMissingCoInsured)
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] show in
                self?.handleItem(.missingCoInsured(type: .coInsured), with: show)
            })
            .store(in: &cancellables)
    }

    private func handleMissingCoOwners() {
        let contractStore: ContractStore = globalAppStateContainer.get()
        contractStore.$activeContracts
            .map(\.hasMissingCoOwners)
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] show in
                self?.handleItem(.missingCoInsured(type: .coOwner), with: show)
            })
            .store(in: &cancellables)
    }

    func handleTerminatedMessage() {
        let store: HomeStore = globalAppStateContainer.get()
        store.$memberContractState
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
    }

    func handleUpdateContactInfo() {
        let store: HomeStore = globalAppStateContainer.get()
        store.$memberInfo
            .compactMap { $0?.isContactInfoUpdateNeeded }
            .removeDuplicates()
            .sink(receiveValue: { [weak self] isContactInfoUpdateNeeded in
                self?.handleItem(.updateContactInfo, with: isContactInfoUpdateNeeded)
            })
            .store(in: &cancellables)
    }

    private func handleMissingPetChipIds() {
        let contractStore: ContractStore = globalAppStateContainer.get()
        contractStore.$activeContracts
            .map { $0.contains { $0.missingPetChipId } }
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] show in
                self?.handleItem(.missingPetChipId, with: show)
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
    case payment
    case payout
    case missingCoInsured(type: StakeholderType)
    case missingPetChipId
    case importantMessage(message: String)
    case renewal
    case terminated
    case updateContactInfo
}

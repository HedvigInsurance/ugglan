import EditStakeholders
import SwiftUI
import hCore
import hCoreUI

struct TodoList: View {
    @EnvironmentObject var navigationVm: HomeNavigationViewModel
    let todos: [Todo]
    @State private var infoView: InfoViewModel?

    var body: some View {
        if !todos.isEmpty {
            hSection(todos) { todo in
                hRow {
                    HStack(spacing: .padding16) {
                        todo.image.accessibilityHidden(true)

                        VStack(alignment: .leading) {
                            hText(todo.title)
                            hText(L10n.homeTodoRequiresActionSubtitle).foregroundColor(hSignalColor.Red.text)
                        }
                        .accessibilityElement(children: .combine)
                        .hTextStyle(.label)
                    }
                    Spacer()
                }
                .withChevronAccessory
                .onTap { open(todo) }
                .hRowContentAlignment(.center)
                .hWithoutHorizontalPadding(.divider)
            }
            .withHeader(title: L10n.homeTodoSectionTitle)
            .sectionContainerStyle(.negative)
            .detent(item: $infoView) { infoViewModel in
                InfoView(infoViewModel: infoViewModel)
            }
        }
    }

    private func open(_ todo: Todo) {
        switch todo {
        case let .paymentOverdue(date):
            let description: String
            if let date {
                description = L10n.InfoCardMissingPayment.missingPaymentsBody(date)
            } else {
                description = L10n.InfoCardMissingPayment.body
            }
            infoView = .init(
                title: nil,
                description: description,
                closeButtonTitle: L10n.General.chatButton,
                actionOnClose: {
                    NotificationCenter.default.post(name: .openChat, object: ChatType.newConversation)
                }
            )
        case .paymentMethodMissing: navigationVm.connectPaymentVm.set()
        case .payoutMethodMissing: navigationVm.isPayoutMethodPresented = true
        case .petChipIdMissing: NotificationCenter.default.post(name: .openMissingPetChipId, object: nil)
        case .contactDetailsMissing: NotificationCenter.default.post(name: .openReviewContactInfo, object: nil)
        case .dataCollectionPermissionMissing: break  // TODO: add it later?
        case .coInsuredMissing:
            navigationVm.editStakeholdersVm.start(stakeholderType: .coInsured, forMissingStakeholders: true)
        case .coOwnerMissing:
            navigationVm.editStakeholdersVm.start(stakeholderType: .coOwner, forMissingStakeholders: true)
        }
    }
}

enum Todo: Identifiable, Comparable, Hashable {
    var id: Todo { self }

    // Identity is by case only — the associated date must not affect equality/hashing,
    // otherwise inserting/removing the todo in `localTodos` (a Set) would miss when the
    // date differs. `String?` is also not `Comparable`, so ordering is defined by case.
    static func == (lhs: Todo, rhs: Todo) -> Bool {
        lhs.sortOrder == rhs.sortOrder
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(sortOrder)
    }

    static func < (lhs: Todo, rhs: Todo) -> Bool {
        lhs.sortOrder < rhs.sortOrder
    }

    private var sortOrder: Int {
        switch self {
        case .paymentOverdue: 0
        case .paymentMethodMissing: 1
        case .payoutMethodMissing: 2
        case .petChipIdMissing: 3
        case .contactDetailsMissing: 4
        case .dataCollectionPermissionMissing: 5
        case .coInsuredMissing: 6
        case .coOwnerMissing: 7
        }
    }

    var title: String {
        switch self {
        case .paymentOverdue: L10n.homeTodoPaymentOverdueTitle
        case .paymentMethodMissing: L10n.homeTodoMissingPaymentMethodTitle
        case .payoutMethodMissing: L10n.homeTodoMissingPayoutMethodTitle
        case .petChipIdMissing: L10n.homeTodoMissingChipIdTitle
        case .contactDetailsMissing: L10n.homeTodoUpdateContactDetailsTitle
        case .dataCollectionPermissionMissing: "Select usage data handling"  // TODO: move to Lokalise
        case .coInsuredMissing: L10n.homeTodoAddCoinsuredTitle
        case .coOwnerMissing: L10n.contractAddAdditionalCoowner
        }
    }

    @MainActor
    @ViewBuilder
    var image: some View {
        switch self {
        case .paymentOverdue: hCoreUIAssets.warningTriangleOutlined.view.foregroundColor(hSignalColor.Red.text)
        case .paymentMethodMissing: hCoreUIAssets.payments.view  // TODO: fix payment missing icon
        case .payoutMethodMissing: hCoreUIAssets.payments.view
        case .petChipIdMissing: hCoreUIAssets.id.view
        case .contactDetailsMissing: hCoreUIAssets.reload.view
        case .dataCollectionPermissionMissing: hCoreUIAssets.eq.view
        case .coInsuredMissing: hCoreUIAssets.profileOutlined.view
        case .coOwnerMissing: hCoreUIAssets.profileOutlined.view  // TODO: fix co-owner missing icon
        }
    }

    case paymentOverdue(date: String?)
    case paymentMethodMissing
    case payoutMethodMissing
    case petChipIdMissing
    case contactDetailsMissing
    case dataCollectionPermissionMissing
    case coInsuredMissing
    case coOwnerMissing
}

#Preview {
    TodoList(
        todos: [
            .paymentOverdue(date: nil),
            .paymentMethodMissing,
            .petChipIdMissing,
            .coOwnerMissing,
            .dataCollectionPermissionMissing,
        ]
        .sorted()
    )
    .environmentObject(HomeNavigationViewModel())
}

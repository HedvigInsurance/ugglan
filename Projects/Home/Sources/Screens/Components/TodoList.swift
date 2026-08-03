import EditStakeholders
import SwiftUI
import hCore
import hCoreUI

struct TodoList: View {
    @EnvironmentObject var navigationVm: HomeNavigationViewModel
    let todos: [Todo]

    var body: some View {
        if !todos.isEmpty {
            hSection(todos) { todo in
                hRow {
                    HStack(spacing: .padding16) {
                        todo.image.accessibilityHidden(true)

                        VStack(alignment: .leading) {
                            hText(todo.title)
                            hText("Requires action").foregroundColor(hSignalColor.Red.text)
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
            .withHeader(title: "To do")
            .sectionContainerStyle(.negative)
        }
    }

    private func open(_ todo: Todo) {
        switch todo {
        case .paymentOverdue: NotificationCenter.default.post(name: .openChat, object: ChatType.newConversation)  // TODO: weird opening chat without any hint (member has to pay and then contact IEX via chat)
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

enum Todo: Identifiable, Comparable {
    var id: Todo { self }

    // TODO: move to Lokalise
    var title: String {
        switch self {
        case .paymentOverdue: "Your payment is overdue"
        case .paymentMethodMissing: "Missing payment method"
        case .payoutMethodMissing: "Missing payout method"
        case .petChipIdMissing: "Missing pet chip-ID"
        case .contactDetailsMissing: "Update contact details"
        case .dataCollectionPermissionMissing: "Select usage data handling"
        case .coInsuredMissing: L10n.contractAddCoinsured
        case .coOwnerMissing: L10n.contractAddAdditionalCoowner
        }
    }

    @MainActor
    @ViewBuilder
    var image: some View {
        switch self {
        case .paymentOverdue: hCoreUIAssets.warningTriangleOutlined.view.foregroundColor(hSignalColor.Red.text)
        case .paymentMethodMissing: hCoreUIAssets.paymentOutlined.view  // TODO: fix payment missing icon
        case .payoutMethodMissing: hCoreUIAssets.paymentOutlined.view
        case .petChipIdMissing: hCoreUIAssets.id.view
        case .contactDetailsMissing: hCoreUIAssets.reload.view
        case .dataCollectionPermissionMissing: hCoreUIAssets.eq.view
        case .coInsuredMissing: hCoreUIAssets.profileOutlined.view
        case .coOwnerMissing: hCoreUIAssets.profileOutlined.view  // TODO: fix co-owner missing icon
        }
    }

    case paymentOverdue
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
            .paymentOverdue,
            .paymentMethodMissing,
            .petChipIdMissing,
            .coOwnerMissing,
            .dataCollectionPermissionMissing,
        ]
        .sorted()
    )
    .environmentObject(HomeNavigationViewModel())
}

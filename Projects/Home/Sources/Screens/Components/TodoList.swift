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
                            hText(L10n.homeTodoRequiresActionSubtitle).foregroundColor(hSignalColor.Red.text)
                        }
                        .hTextStyle(.label)
                    }
                    Spacer()
                }
                .withChevronAccessory
                .onTap { open(todo) }
                .hRowContentAlignment(.center)
                .hWithoutHorizontalPadding(.divider)
                .accessibilityElement(children: .combine)
                .accessibilityHint(L10n.voiceoverPressTo + " " + L10n.a11YViewDetails)
            }
            .withHeader(title: L10n.homeTodoSectionTitle)
            .sectionContainerStyle(.negative)
        }
    }

    private func open(_ todo: Todo) {
        switch todo {
        case .payoutMethodMissing: navigationVm.isPayoutMethodPresented = true
        case .petChipIdMissing: NotificationCenter.default.post(name: .openMissingPetChipId, object: nil)
        case .contactDetailsMissing: NotificationCenter.default.post(name: .openReviewContactInfo, object: nil)
        case .dataCollectionPermissionMissing: NotificationCenter.default.post(name: .openAnalyticsConsent, object: nil)
        case .coInsuredMissing:
            navigationVm.editStakeholdersVm.start(stakeholderType: .coInsured, forMissingStakeholders: true)
        case .coOwnerMissing:
            navigationVm.editStakeholdersVm.start(stakeholderType: .coOwner, forMissingStakeholders: true)
        }
    }
}

enum Todo: Identifiable, Comparable, Hashable {
    var id: Todo { self }

    // Identity and ordering are both defined by case, via `sortOrder`.
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
        case .payoutMethodMissing: 0
        case .petChipIdMissing: 1
        case .contactDetailsMissing: 2
        case .dataCollectionPermissionMissing: 3
        case .coInsuredMissing: 4
        case .coOwnerMissing: 5
        }
    }

    var title: String {
        switch self {
        case .payoutMethodMissing: L10n.homeTodoMissingPayoutMethodTitle
        case .petChipIdMissing: L10n.homeTodoMissingChipIdTitle
        case .contactDetailsMissing: L10n.homeTodoUpdateContactDetailsTitle
        case .dataCollectionPermissionMissing: L10n.homeTodoSelectUsageDataTitle
        case .coInsuredMissing: L10n.homeTodoAddCoinsuredTitle
        case .coOwnerMissing: L10n.homeTodoAddCoownerTitle
        }
    }

    @MainActor
    @ViewBuilder
    var image: some View {
        switch self {
        case .payoutMethodMissing: hCoreUIAssets.payments.view
        case .petChipIdMissing: hCoreUIAssets.id.view
        case .contactDetailsMissing: hCoreUIAssets.infoOutlined.view
        case .dataCollectionPermissionMissing: hCoreUIAssets.eq.view
        case .coInsuredMissing: hCoreUIAssets.profileOutlined.view
        case .coOwnerMissing: hCoreUIAssets.profileOutlined.view
        }
    }

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
            .petChipIdMissing,
            .coOwnerMissing,
            .dataCollectionPermissionMissing,
        ]
        .sorted()
    )
    .environmentObject(HomeNavigationViewModel())
}

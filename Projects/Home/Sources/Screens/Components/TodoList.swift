import AppStateContainer
import Claims
import EditStakeholdersCore
import EditStakeholdersUI
import SwiftUI
import hCore
import hCoreUI

struct TodoList: View {
    @Environment(HomeNavigationViewModel.self) var navigationVm
    @AppObservedObject private var claimsStore: ClaimsStore
    let todos: [Todo]

    var body: some View {
        if !todos.isEmpty {
            hSection(todos) { todo in
                hRow {
                    HStack(spacing: .padding16) {
                        todo.image.accessibilityHidden(true)

                        VStack(alignment: .leading) {
                            hText(title(for: todo))
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
            .sectionContainerDecorations([.border, .shadow])
        }
    }

    private var followupWithQuestionsLeft: ClaimFollowup? {
        claimsStore.followups.last(where: { $0.isOpen && $0.questionsLeft > 0 })
    }

    private var followupClaim: ClaimModel? {
        let claimId = followupWithQuestionsLeft?.claimId
        return claimsStore.allActiveClaims
            .compactMap { activeClaim -> ClaimModel? in
                if case .claim(let model) = activeClaim { return model }
                return nil
            }
            .first(where: { $0.id == claimId })
    }

    private func title(for todo: Todo) -> String {
        guard todo == .claimFollowupOpen, let claimType = followupClaim?.claimType, !claimType.isEmpty else {
            return todo.title
        }
        return L10n.homeTodoClaimFollowupCompleteTitle(claimType.lowercased())
    }

    private func open(_ todo: Todo) {
        switch todo {
        case .claimFollowupOpen:
            if let followupClaim, followupClaim.status != .closed, !followupClaim.isPartnerClaim {
                navigationVm.router.push(followupClaim)
            } else {
                navigationVm.claimFollowup = followupWithQuestionsLeft
            }
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
        case .claimFollowupOpen: 0
        case .payoutMethodMissing: 1
        case .petChipIdMissing: 2
        case .contactDetailsMissing: 3
        case .dataCollectionPermissionMissing: 4
        case .coInsuredMissing: 5
        case .coOwnerMissing: 6
        }
    }

    var title: String {
        switch self {
        case .claimFollowupOpen: L10n.homeTodoClaimFollowupCompleteGenericTitle
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
        case .claimFollowupOpen: hCoreUIAssets.documentPlus.view
        case .payoutMethodMissing: hCoreUIAssets.payments.view
        case .petChipIdMissing: hCoreUIAssets.id.view
        case .contactDetailsMissing: hCoreUIAssets.infoOutlined.view
        case .dataCollectionPermissionMissing: hCoreUIAssets.eq.view
        case .coInsuredMissing: hCoreUIAssets.profileOutlined.view
        case .coOwnerMissing: hCoreUIAssets.profileOutlined.view
        }
    }

    case claimFollowupOpen
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
    .environment(HomeNavigationViewModel())
}

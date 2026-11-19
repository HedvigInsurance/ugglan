import ContractsCore
import EditStakeholdersCore
import PowerOfAttorneyCore
import SwiftUI
import hCore
import hCoreUI

struct PowerOfAttorneySelectCoInsuredScreen: View {
    @State private var vm = PowerOfAttorneySelectCoInsuredViewModel()
    @Environment(NavigationRouter.self) private var router

    var body: some View {
        form
            .loading($vm.viewState)
            .hStateViewButtonConfig(
                .init(
                    actionButton: .init(buttonAction: { [vm] in
                        Task { await vm.fetchCoInsured() }
                    }),
                    dismissButton: nil
                )
            )
            .detent(presented: $vm.isUserPickerPresented) {
                userPicker
                    // TODO: Localize via Lokalise
                    .navigationTitle("Co-insured")
                    .embededInNavigation(
                        options: .navigationType(type: .large),
                        tracking: PowerOfAttorneyDetentType.userPicker
                    )
            }
            .detent(presented: $vm.isLevelPickerPresented) {
                levelPicker
                    // TODO: Localize via Lokalise
                    .navigationTitle("Level")
                    .embededInNavigation(
                        options: .navigationType(type: .large),
                        tracking: PowerOfAttorneyDetentType.levelPicker
                    )
            }
            .task { [vm, router] in
                vm.onShare = { user, level in
                    router.push(PowerOfAttorneyRouterType.signing(user: user, level: level))
                }
                await vm.fetchCoInsured()
            }
    }

    private var form: some View {
        hForm {
            VStack(spacing: .padding8) {
                VStack(spacing: .padding4) {
                    if vm.enterPersonalNumber || vm.users.isEmpty {
                        personalNumberFields
                    } else {
                        userDropdown
                    }
                    if !vm.users.isEmpty {
                        enterPersonalNumberToggle
                    }
                }
                levelDropdown
            }
            .hFieldSize(.medium)
        }
        .hFormContentPosition(.bottom)
        .hFormTitle(
            // TODO: Localize via Lokalise
            title: .init(.none, .body1, "Add power of attorney", alignment: .leading),
            subTitle: .init(
                .none,
                .body1,
                // TODO: Localize via Lokalise
                "Select someone from your co-insured or add by SSN and choose permission level",
                alignment: .leading
            )
        )
        .hFormAttachToBottom {
            hSection {
                hButton(
                    .large,
                    .primary,
                    // TODO: Localize "Share" via Lokalise
                    content: .init(title: vm.needsPersonalNumberLookup ? L10n.contractSsnFetchInfo : "Share")
                ) { [vm] in
                    await vm.primaryAction()
                }
                .hButtonIsLoading(vm.isLookingUpPersonalNumber)
                .disabled(vm.needsPersonalNumberLookup && !vm.isPersonalNumberValid)
            }
            .sectionContainerStyle(.transparent)
            .padding(.vertical, .padding16)
        }
    }

    private var userDropdown: some View {
        DropdownView(
            value: vm.selectedUser?.fullName ?? "",
            // TODO: Localize via Lokalise
            placeHolder: "Co-insured",
            error: $vm.userError
        ) { [vm] in
            vm.isUserPickerPresented = true
        }
        .sectionContainerStyle(.transparent)
    }

    /// Same fields as when adding a co-insured: personal number, then the name looked up from it (locked).
    @ViewBuilder
    private var personalNumberFields: some View {
        hSection {
            hFloatingTextField(
                masking: Masking(type: .personalNumber(minAge: 0)),
                value: $vm.personalNumber,
                placeholder: L10n.contractPersonalIdentity,
                error: $vm.personalNumberError,
                textFieldPlaceholder: L10n.editCoinsuredSsnPlaceholder
            )
        }
        .disabled(vm.isLookingUpPersonalNumber)
        .sectionContainerStyle(.transparent)
        if let user = vm.lookedUpUser {
            hSection {
                hFloatingField(value: user.fullName, placeholder: L10n.fullNameText, onTap: {})
                    .hFieldTrailingView {
                        hCoreUIAssets.lock.view
                            .foregroundColor(hTextColor.Opaque.secondary)
                    }
            }
            .hBackgroundOption(option: [.locked])
            .disabled(true)
            .sectionContainerStyle(.transparent)
        }
    }

    private var enterPersonalNumberToggle: some View {
        CheckboxToggleView(
            title: "Enter personal number instead",
            isOn: $vm.enterPersonalNumber
        )
    }

    private var levelDropdown: some View {
        DropdownView(
            value: vm.selectedLevel?.displayName ?? "",
            // TODO: Localize via Lokalise
            placeHolder: "Level",
            error: $vm.levelError
        ) { [vm] in
            vm.isLevelPickerPresented = true
        }
        .sectionContainerStyle(.transparent)
    }

    private var userPicker: some View {
        ItemPickerScreen<PowerOfAttorneyUser>(
            config: .init(
                items: vm.users.map { user in
                    (object: user, displayName: .init(title: user.fullName, subTitle: user.ssn))
                },
                preSelectedItems: { [vm] in
                    vm.selectedUser.map { [$0] } ?? []
                },
                onSelected: { [vm] selected in
                    if let user = selected.first?.0 {
                        vm.select(user: user)
                    }
                    vm.isUserPickerPresented = false
                },
                onCancel: { [vm] in
                    vm.isUserPickerPresented = false
                }
            )
        )
        .hItemPickerAttributes([.singleSelect, .disableIfNoneSelected])
        .hFormContentPosition(.compact)
    }

    private var levelPicker: some View {
        ItemPickerScreen<PowerOfAttorneyLevel>(
            config: .init(
                items: PowerOfAttorneyLevel.allCases.map { level in
                    (object: level, displayName: .init(title: level.displayName))
                },
                preSelectedItems: { [vm] in
                    vm.selectedLevel.map { [$0] } ?? []
                },
                onSelected: { [vm] selected in
                    if let level = selected.first?.0 {
                        vm.select(level: level)
                    }
                    vm.isLevelPickerPresented = false
                },
                onCancel: { [vm] in
                    vm.isLevelPickerPresented = false
                },
                returnValueOnSelection: true
            )
        )
        .hItemPickerAttributes([.singleSelect])
        .hFormContentPosition(.compact)
    }
}

enum PowerOfAttorneyDetentType: TrackingViewNameProtocol {
    case userPicker
    case levelPicker

    var nameForTracking: String {
        switch self {
        case .userPicker:
            return "PowerOfAttorneyUserPicker"
        case .levelPicker:
            return "PowerOfAttorneyLevelPicker"
        }
    }
}

@MainActor
@Observable
final class PowerOfAttorneySelectCoInsuredViewModel {
    var viewState: ProcessingState = .loading
    var users: [PowerOfAttorneyUser] = []

    // Picking one of the co-insured
    var selectedUser: PowerOfAttorneyUser?
    var userError: String?
    var isUserPickerPresented = false

    // Entering a personal number instead
    var enterPersonalNumber = false {
        didSet {
            guard enterPersonalNumber != oldValue else { return }
            userError = nil
            personalNumberError = nil
        }
    }
    var personalNumber = "" {
        didSet {
            guard personalNumber != oldValue else { return }
            // A changed personal number has to be looked up again
            lookedUpUser = nil
            personalNumberError = nil
        }
    }
    var lookedUpUser: PowerOfAttorneyUser?
    var personalNumberError: String?
    var isLookingUpPersonalNumber = false

    var selectedLevel: PowerOfAttorneyLevel?
    var levelError: String?
    var isLevelPickerPresented = false

    @ObservationIgnored var onShare: ((PowerOfAttorneyUser, PowerOfAttorneyLevel) -> Void)?
    @ObservationIgnored private let service = PowerOfAttorneyService()
    @ObservationIgnored private let personalNumberMasking = Masking(type: .personalNumber(minAge: 0))

    var isPersonalNumberValid: Bool {
        personalNumberMasking.isValid(text: personalNumber)
    }

    /// The name for an entered personal number has to be fetched before sharing.
    var needsPersonalNumberLookup: Bool {
        enterPersonalNumber && lookedUpUser == nil
    }

    func fetchCoInsured() async {
        withAnimation { viewState = .loading }
        do {
            users = try await service.getCoInsured()
            // Nobody to pick from, go straight to entering a personal number
            if users.isEmpty {
                enterPersonalNumber = true
            }
            withAnimation { viewState = .success }
        } catch {
            withAnimation { viewState = .error(errorMessage: error.localizedDescription) }
        }
    }

    func select(user: PowerOfAttorneyUser) {
        selectedUser = user
        userError = nil
    }

    func select(level: PowerOfAttorneyLevel) {
        selectedLevel = level
        levelError = nil
    }

    func primaryAction() async {
        if needsPersonalNumberLookup {
            await lookUpPersonalNumber()
        } else {
            share()
        }
    }

    private func lookUpPersonalNumber() async {
        withAnimation {
            personalNumberError = nil
            isLookingUpPersonalNumber = true
        }
        do {
            let user = try await service.getUser(
                personalNumber: personalNumberMasking.unmaskedValue(text: personalNumber)
            )
            withAnimation { lookedUpUser = user }
        } catch {
            withAnimation { personalNumberError = error.localizedDescription }
        }
        withAnimation { isLookingUpPersonalNumber = false }
    }

    private func share() {
        let user = enterPersonalNumber ? lookedUpUser : selectedUser
        withAnimation {
            if user == nil {
                // TODO: Localize via Lokalise
                userError = "Choose a co-insured"
            }
            if selectedLevel == nil {
                // TODO: Localize via Lokalise
                levelError = "Choose a level"
            }
        }
        guard let user, let selectedLevel else { return }
        onShare?(user, selectedLevel)
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> PowerOfAttorneyClient in PowerOfAttorneyClientDemo() })
    Dependencies.shared.add(module: Module { () -> FetchContractsClient in FetchContractsClientDemo() })
    Dependencies.shared.add(module: Module { () -> EditStakeholdersClient in EditStakeholdersClientDemo() })
    return PowerOfAttorneySelectCoInsuredScreen()
        .environment(NavigationRouter())
}

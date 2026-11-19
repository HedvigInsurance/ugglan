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
            VStack(spacing: .padding4) {
                if vm.enterPersonalNumber || vm.users.isEmpty {
                    personalNumberFields
                } else {
                    userList
                }
                if !vm.users.isEmpty {
                    enterPersonalNumberToggle
                }
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
                    content: .init(title: vm.needsPersonalNumberLookup ? L10n.contractSsnFetchInfo : "Add")
                ) { [vm] in
                    await vm.primaryAction()
                }
                .hButtonIsLoading(vm.isLookingUpPersonalNumber)
                .disabled(vm.needsPersonalNumberLookup && !vm.isPersonalNumberValid)
            }
            .sectionContainerStyle(.transparent)
            .padding(.vertical, .padding16)
        }
        .animation(.easeInOut, value: vm.enterPersonalNumber)
    }

    private var userList: some View {
        hSection {
            hRadioOptionList(vm.users) { user in
                hRadioOption(
                    value: user,
                    selection: userSelection,
                    item: .init(title: user.fullName, subTitle: user.ssn)
                )
            }
            .addFieldError(animate: .constant(false), error: $vm.userError)
        }
        .sectionContainerStyle(.transparent)
    }

    private var userSelection: Binding<PowerOfAttorneyUser?> {
        Binding(
            get: { [vm] in vm.selectedUser },
            set: { [vm] user in
                if let user {
                    vm.select(user: user)
                }
            }
        )
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

    private var levelPicker: some View {
        ItemPickerScreen<PowerOfAttorneyLevel>(
            config: .init(
                items: PowerOfAttorneyLevel.allCases.map { level in
                    (object: level, displayName: .init(title: level.displayName))
                },
                preSelectedItems: { [] },
                onSelected: { [vm] selected in
                    vm.isLevelPickerPresented = false
                    if let level = selected.first?.0 {
                        vm.shareWithSelectedUser(level: level)
                    }
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
    case levelPicker

    var nameForTracking: String {
        switch self {
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

    /// Shown after pressing add with a co-insured selected. An entered personal number always gets full access.
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
        if enterPersonalNumber {
            guard let lookedUpUser else { return }
            onShare?(lookedUpUser, .full)
        } else if selectedUser == nil {
            // TODO: Localize via Lokalise
            withAnimation { userError = "Choose a co-insured" }
        } else {
            isLevelPickerPresented = true
        }
    }

    func shareWithSelectedUser(level: PowerOfAttorneyLevel) {
        guard let selectedUser else { return }
        onShare?(selectedUser, level)
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> PowerOfAttorneyClient in PowerOfAttorneyClientDemo() })
    Dependencies.shared.add(module: Module { () -> FetchContractsClient in FetchContractsClientDemo() })
    Dependencies.shared.add(module: Module { () -> EditStakeholdersClient in EditStakeholdersClientDemo() })
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })

    return PowerOfAttorneySelectCoInsuredScreen()
        .environment(NavigationRouter())
}

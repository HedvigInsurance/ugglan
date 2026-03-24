import Combine
import Home
import PresentableStore
import SwiftUI
import hCore
import hCoreUI

public struct MyInfoView: View {
    @EnvironmentObject var router: NavigationRouter
    @StateObject var vm = MyInfoViewModel()
    let presentationMode: PresentationMode

    public init(presentationMode: PresentationMode = .navigation) {
        self.presentationMode = presentationMode
    }

    public var body: some View {
        hForm {}
            .hFormAttachToBottom {
                hSection {
                    VStack(spacing: .padding16) {
                        VStack(spacing: .padding4) {
                            infoCardView
                            emailField
                            phoneNumberField

                            if let error = vm.error {
                                InfoCard(text: error, type: .error)
                            }
                        }
                        buttonView
                    }
                }
                .sectionContainerStyle(.transparent)
                .disabled(vm.viewState == .loading)
            }
            .hFormContentPosition(presentationMode == .sheet ? .compact : .top)
    }

    @ViewBuilder
    private var infoCardView: (some View)? {
        if vm.showInfoCard, case .navigation = presentationMode {
            InfoCard(text: L10n.profileMyInfoReviewInfoCard, type: .info)
        }
    }

    private var phoneNumberField: some View {
        hFloatingTextField(
            masking: .init(type: .digits),
            value: $vm.currentPhoneInput,
            equals: $vm.type,
            focusValue: .phone,
            placeholder: L10n.phoneNumberRowTitle,
            error: $vm.phoneError
        )
    }

    private var emailField: some View {
        hFloatingTextField(
            masking: .init(type: .email),
            value: $vm.currentEmailInput,
            equals: $vm.type,
            focusValue: .email,
            placeholder: L10n.emailRowTitle,
            error: $vm.emailError
        )
    }

    private var buttonView: some View {
        VStack(spacing: .padding8) {
            hSaveButton(.primary) {
                Task { [weak vm, weak router] in
                    let success = await vm?.save() ?? false
                    if success && presentationMode == .sheet {
                        router?.dismiss()
                    }
                }
            }
            .hButtonIsLoading(vm.viewState == .loading)
            .disabled(vm.disabledSaveButton)

            if presentationMode == .sheet {
                hCloseButton(.secondary) { router.dismiss() }
            }
        }
    }
}

extension MyInfoView {
    public enum PresentationMode {
        case navigation
        case sheet
    }
}

@MainActor
public class MyInfoViewModel: ObservableObject {
    private let profileService = ProfileService()
    @PresentableStore var profileStore: ProfileStore
    @PresentableStore var homeStore: HomeStore
    @Published var type: MyInfoViewEditType?
    @Published var currentPhoneInput: String = ""
    @Published var phoneError: String?
    @Published var currentEmailInput: String = ""
    @Published var emailError: String?
    @Published var error: String?
    @Published var viewState: ProcessingState = .success
    @Published var disabledSaveButton: Bool = false

    private var cancellables = Set<AnyCancellable>()
    @Published var showInfoCard: Bool

    init() {
        let store: ProfileStore = globalPresentableStoreContainer.get()
        showInfoCard = store.state.memberDetails?.isContactInfoUpdateNeeded ?? false
        currentPhoneInput = store.state.memberDetails?.phone ?? ""
        currentEmailInput = store.state.memberDetails?.email ?? ""
        $currentPhoneInput
            .delay(for: 0.05, scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.isValid()
            }
            .store(in: &cancellables)
        $currentEmailInput
            .delay(for: 0.05, scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.isValid()
            }
            .store(in: &cancellables)

        store.stateSignal
            .receive(on: RunLoop.main)
            .map(\.memberDetails?.isContactInfoUpdateNeeded)
            .removeDuplicates()
            .sink { [weak self] state in
                self?.showInfoCard = state ?? false
            }
            .store(in: &cancellables)
    }

    func isValid() {
        withAnimation {
            disabledSaveButton = !hasValidPhoneNumber || !hasValidEmail
        }
    }

    private var hasValidPhoneNumber: Bool {
        currentPhoneInput.isValidPhone && phoneError == nil
    }

    private var hasValidEmail: Bool {
        currentEmailInput != "" && emailError == nil
    }

    @MainActor
    func save() async -> Bool {
        withAnimation {
            error = nil
            viewState = .loading
        }

        do {
            try await validateAndUpdateContactInfo()
            withAnimation {
                viewState = .success
            }
            Toasts.shared.displayToastBar(
                toast: .init(
                    type: .campaign,
                    icon: hCoreUIAssets.checkmark.view,
                    text: L10n.profileMyInfoSaveSuccessToastBody
                )
            )
            homeStore.send(.fetchMemberState)
        } catch {
            if let error = error as? MyInfoSaveError {
                switch error {
                case .emailEmpty, .emailMalformed:
                    withAnimation {
                        self.emailError = error.localizedDescription
                    }
                case .phoneNumberEmpty, .phoneNumberMalformed:
                    withAnimation {
                        self.phoneError = error.localizedDescription
                    }
                case let .error(message):
                    withAnimation {
                        self.error = message
                    }
                }
                withAnimation {
                    viewState = .error(errorMessage: error.localizedDescription)
                }
            } else {
                viewState = .error(errorMessage: error.localizedDescription)
                self.error = error.localizedDescription
            }
            isValid()
            return false
        }
        return true
    }

    private func validateAndUpdateContactInfo() async throws {
        if currentPhoneInput.isEmpty {
            throw MyInfoSaveError.phoneNumberEmpty
        }
        if currentEmailInput.isEmpty {
            throw MyInfoSaveError.emailEmpty
        }
        if !Masking(type: .email).isValid(text: currentEmailInput) {
            throw MyInfoSaveError.emailMalformed
        }
        let updatedContactData = try await profileService.update(
            email: currentEmailInput,
            phone: currentPhoneInput
        )

        let newPhone = updatedContactData.phone
        let newEmail = updatedContactData.email

        profileStore.send(.setMemberPhone(phone: newPhone))
        profileStore.send(.setMemberEmail(email: newEmail))
    }

    enum MyInfoViewEditType: hTextFieldFocusStateCompliant {
        static var last: MyInfoViewEditType {
            MyInfoViewEditType.email
        }

        var next: MyInfoViewEditType? {
            switch self {
            case .phone:
                return .email
            case .email:
                return nil
            }
        }

        case phone
        case email
    }
}

#Preview {
    let store: ProfileStore = globalPresentableStoreContainer.get()
    store.send(
        .setMember(
            memberData: .init(
                id: "1",
                firstName: "Ma",
                lastName: "",
                phone: "",
                email: "sladjann@gmail.com",
                hasTravelCertificate: true,
                isContactInfoUpdateNeeded: true
            )
        )
    )
    return NavigationView {
        MyInfoView()
    }
}

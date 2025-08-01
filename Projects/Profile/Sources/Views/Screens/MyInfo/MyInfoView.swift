import Combine
import PresentableStore
import SwiftUI
import hCore
import hCoreUI

public struct MyInfoView: View {
    @StateObject var vm = MyInfoViewModel()

    public init() {}

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
                                hText(error, style: .label)
                                    .foregroundColor(hSignalColor.Amber.text)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        buttonView
                    }
                }
                .sectionContainerStyle(.transparent)
                .disabled(vm.viewState == .loading)
            }
    }

    @ViewBuilder
    private var infoCardView: (some View)? {
        if vm.showInfoCard {
            InfoCard(text: L10n.profileMyInfoReviewInfoCard, type: .info)
        }
    }

    private var emailField: some View {
        hFloatingTextField(
            masking: .init(type: .digits),
            value: $vm.currentPhoneInput,
            equals: $vm.type,
            focusValue: .phone,
            placeholder: L10n.phoneNumberRowTitle,
            error: $vm.phoneError
        )
    }

    private var phoneNumberField: some View {
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
        hButton(
            .large,
            .primary,
            content: .init(title: L10n.generalSaveButton),
            {
                Task {
                    await vm.save()
                }
            }
        )
        .hButtonIsLoading(vm.viewState == .loading)
        .disabled(vm.disabledSaveButton)
        .padding(.bottom, .padding8)
    }
}

@MainActor
public class MyInfoViewModel: ObservableObject {
    var profileService = ProfileService()
    @PresentableStore var store: ProfileStore
    @Published var type: MyInfoViewEditType?
    @Published var currentPhoneInput: String = ""
    @Published var phoneError: String?
    @Published var currentEmailInput: String = ""
    @Published var emailError: String?
    @Published var error: String?
    @Published var viewState: ProcessingState = .success
    @Published var disabledSaveButton: Bool = false

    private var originalPhone: String
    private var originalEmail: String
    private var cancellables = Set<AnyCancellable>()
    @Published var showInfoCard: Bool

    init() {
        let store: ProfileStore = globalPresentableStoreContainer.get()
        showInfoCard = store.state.memberDetails?.isContactInfoUpdateNeeded ?? false
        originalPhone = store.state.memberDetails?.phone ?? ""
        originalEmail = store.state.memberDetails?.email ?? ""
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
    func save() async {
        error = nil
        withAnimation {
            viewState = .loading
        }
        async let updateAsync: () = getFuture()
        do {
            _ = try await [updateAsync]
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
            }
            isValid()
        }
    }

    private func getFuture() async throws {
        if currentPhoneInput.isEmpty {
            throw MyInfoSaveError.phoneNumberEmpty
        } else if currentEmailInput.isEmpty {
            throw MyInfoSaveError.emailEmpty
        }

        if !Masking(type: .email).isValid(text: currentEmailInput) {
            throw MyInfoSaveError.emailMalformed
        }

        do {
            let updatedContactData = try await profileService.update(
                email: currentEmailInput,
                phone: currentPhoneInput
            )

            let newPhone = updatedContactData.phone
            let newEmail = updatedContactData.email

            originalPhone = newPhone
            originalEmail = newEmail

            store.send(.setMemberPhone(phone: newPhone))
            store.send(.setMemberEmail(email: newEmail))
        } catch let exception {
            throw MyInfoSaveError.error(message: exception.localizedDescription)
        }
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

struct MyInfoView_Previews: PreviewProvider {
    static var previews: some View {
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
}

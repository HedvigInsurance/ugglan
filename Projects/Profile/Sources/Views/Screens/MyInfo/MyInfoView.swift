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
            value: $vm.phone,
            equals: $vm.type,
            focusValue: .phone,
            placeholder: L10n.phoneNumberRowTitle,
            error: $vm.phoneError
        )
    }

    private var phoneNumberField: some View {
        hFloatingTextField(
            masking: .init(type: .email),
            value: $vm.email,
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
    @Published var phone: String = ""
    @Published var phoneError: String?
    @Published var email: String = ""
    @Published var emailError: String?
    @Published var viewState: ProcessingState = .success
    @Published var disabledSaveButton: Bool = false

    private var originalPhone: String
    private var originalEmail: String
    private var cancellables = Set<AnyCancellable>()
    var showInfoCard: Bool {
        guard let phoneNumber = store.state.memberDetails?.phone, !phoneNumber.isEmpty else {
            return true
        }
        guard let email = store.state.memberDetails?.email, !email.isEmpty else {
            return true
        }
        return false
    }

    init() {
        let store: ProfileStore = globalPresentableStoreContainer.get()
        originalPhone = store.state.memberDetails?.phone ?? ""
        originalEmail = store.state.memberDetails?.email ?? ""
        phone = store.state.memberDetails?.phone ?? ""
        email = store.state.memberDetails?.email ?? ""
        $phone
            .delay(for: 0.05, scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.isValid()
            }
            .store(in: &cancellables)
        $email
            .delay(for: 0.05, scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.isValid()
            }
            .store(in: &cancellables)
    }

    func isValid() {
        withAnimation {
            disabledSaveButton = (phone == "" || originalPhone == "") || (email == "" || originalEmail == "")
        }
    }

    @MainActor
    func save() async {
        withAnimation {
            viewState = .loading
        }
        async let updateAsync: () = self.getFuture()
        do {
            _ = try await [updateAsync]
            withAnimation {
                viewState = .success
            }
            Toasts.shared.displayToastBar(
                toast: .init(
                    type: .campaign,
                    icon: hCoreUIAssets.edit.image,
                    text: L10n.profileMyInfoSaveSuccessToastBody
                )
            )
        } catch let error {
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
                }
                withAnimation {
                    viewState = .error(errorMessage: error.localizedDescription)
                }
            }
        }
    }

    private func getFuture() async throws {
        if originalPhone != phone || originalEmail != email {
            if phone.isEmpty {
                throw MyInfoSaveError.phoneNumberEmpty
            } else if email.isEmpty {
                throw MyInfoSaveError.emailEmpty
            }

            if !Masking(type: .email).isValid(text: email) {
                throw MyInfoSaveError.emailMalformed
            }

            do {

                let updatedContactData = try await profileService.update(email: email, phone: phone)

                let newPhone = updatedContactData.phone
                let newEmail = updatedContactData.email

                self.originalPhone = newPhone
                self.originalEmail = newEmail

                self.store.send(.setMemberPhone(phone: newPhone))
                self.store.send(.setMemberEmail(email: newEmail))
            } catch let exception {
                MyInfoSaveError.phoneNumberMalformed  // TODO: Change
            }

        }
    }

    enum MyInfoViewEditType: hTextFieldFocusStateCompliant {
        static var last: MyInfoViewEditType {
            return MyInfoViewEditType.email
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
                    hasTravelCertificate: true
                )
            )
        )
        return NavigationView {
            MyInfoView()
        }
    }
}

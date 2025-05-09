import Combine
import PresentableStore
import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect
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
                .disabled(vm.isLoading)
            }
    }

    private var infoCardView: some View {
        InfoCard(text: "Review and update your contact info. We’ll only get in touch when it matters.", type: .info)
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
        hButton.LargeButton(type: .primary) {
            Task {
                withAnimation {
                    vm.isLoading = true
                }
                await vm.save()
                withAnimation {
                    vm.isLoading = false
                    vm.checkForChanges()
                }
            }
        } content: {
            hText(L10n.generalSaveButton)
        }
        .hButtonIsLoading(vm.isLoading)
        .disabled(!vm.inEditMode)
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
    @Published var inEditMode: Bool = false
    @Published var isLoading: Bool = false

    weak var vc: UIViewController?
    private var originalPhone: String
    private var originalEmail: String
    private var cancellables = Set<AnyCancellable>()

    init() {
        let store: ProfileStore = globalPresentableStoreContainer.get()
        originalPhone = store.state.memberDetails?.phone ?? ""
        originalEmail = store.state.memberDetails?.email ?? ""
        phone = store.state.memberDetails?.phone ?? ""
        email = store.state.memberDetails?.email ?? ""
        $phone
            .delay(for: 0.05, scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.checkForChanges()
            }
            .store(in: &cancellables)
        $email
            .delay(for: 0.05, scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.checkForChanges()
            }
            .store(in: &cancellables)
    }

    func checkForChanges() {
        withAnimation {
            inEditMode = originalPhone != phone || originalEmail != email
        }
    }

    @MainActor
    func save() async {
        async let updatePhoneAsync: () = self.getPhoneFuture()
        async let updateEmailAsync: () = self.getEmailFuture()
        do {
            _ = try await [updatePhoneAsync, updateEmailAsync]
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
            }
        }
    }

    private func getPhoneFuture() async throws {
        if originalPhone != phone {
            if phone.isEmpty {
                throw MyInfoSaveError.phoneNumberEmpty
            }
            do {
                let newPhone = try await profileService.update(phone: phone)
                self.originalPhone = newPhone
                self.store.send(.setMemberPhone(phone: newPhone))
            } catch {
                throw MyInfoSaveError.phoneNumberMalformed
            }

        }
    }

    private func getEmailFuture() async throws {
        if originalEmail != email {
            if email.isEmpty {
                throw MyInfoSaveError.emailEmpty
            }
            if !Masking(type: .email).isValid(text: email) {
                throw MyInfoSaveError.emailMalformed
            }
            do {
                let newEmail = try await profileService.update(email: email)
                self.originalEmail = newEmail
                self.store.send(.setMemberEmail(email: newEmail))
            } catch {
                throw MyInfoSaveError.emailMalformed
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

import Combine
import PresentableStore
import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect
import hCore
import hCoreUI
import hGraphQL

public struct MyInfoView: View {
    @StateObject var vm = MyInfoViewModel()

    public init() {}

    public var body: some View {
        hUpdatedForm {
            hSection {
                VStack(spacing: 4) {
                    hFloatingTextField(
                        masking: .init(type: .digits),
                        value: $vm.phone,
                        equals: $vm.type,
                        focusValue: .phone,
                        placeholder: L10n.phoneNumberRowTitle,
                        error: $vm.phoneError
                    )
                    hFloatingTextField(
                        masking: .init(type: .email),
                        value: $vm.email,
                        equals: $vm.type,
                        focusValue: .email,
                        placeholder: L10n.emailRowTitle,
                        error: $vm.emailError
                    )
                }
                .disabled(vm.isLoading)
            }
            .padding(.top, .padding8)
        }
        .hFormAttachToBottom({
            hSection {
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
            }
            .sectionContainerStyle(.transparent)
            .padding(.bottom, .padding8)
            .opacity(vm.inEditMode ? 1 : 0)
        })
        .sectionContainerStyle(.transparent)
        .introspect(.viewController, on: .iOS(.v13...)) { vc in
            self.vm.vc = vc
        }
        .alert(isPresented: $vm.showAlert) {
            cancelAlert
        }
        .navigationTitle(L10n.profileMyInfoRowTitle)

    }

    @ToolbarContentBuilder
    private var toolbars: some ToolbarContent {
        Group {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(L10n.myInfoCancelButton) {
                    vm.cancel()
                }
                .foregroundColor(hTextColor.Opaque.primary)
                .opacity(vm.inEditMode ? 1 : 0)
                .transition(.opacity.animation(.easeInOut(duration: 0.2)))
                .disabled(!vm.inEditMode)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                if vm.isLoading {
                    ProgressView().foregroundColor(hTextColor.Opaque.primary)
                        .transition(.opacity.animation(.easeInOut(duration: 0.2)))

                } else {
                    Button(L10n.generalDoneButton) {
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
                    }
                    .foregroundColor(hTextColor.Opaque.primary)
                    .opacity(vm.inEditMode ? 1 : 0)
                    .transition(.opacity.animation(.easeInOut(duration: 0.2)))
                    .disabled(!vm.inEditMode)
                }
            }
        }
    }

    private var cancelAlert: SwiftUI.Alert {
        return Alert(
            title: Text(L10n.myInfoCancelAlertTitle),
            message: Text(L10n.myInfoCancelAlertMessage),
            primaryButton: .default(Text(L10n.myInfoCancelAlertButtonCancel)),
            secondaryButton: .destructive(Text(L10n.myInfoCancelAlertButtonConfirm)) {
                vm.vc?.navigationController?.popViewController(animated: true)
            }
        )
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
    @Published var showAlert: Bool = false
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

    func cancel() {
        showAlert = true
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

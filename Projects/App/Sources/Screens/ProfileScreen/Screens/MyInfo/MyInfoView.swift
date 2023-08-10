import Combine
import Flow
import Form
import Presentation
import SwiftUI
import UIKit
import hAnalytics
import hCore
import hCoreUI
import hGraphQL

struct MyInfoView: View {
    @StateObject var vm = MyInfoViewModel()
    var body: some View {
        hForm {
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
            }
            .padding(.top, 8)
        }
        .sectionContainerStyle(.transparent)
        .disabled(vm.isLoading)
        .navigationBarBackButtonHidden(vm.inEditMode)
        .toolbar {
            toolbars
        }
        .introspectViewController { vc in
            self.vm.vc = vc
        }
        .alert(isPresented: $vm.showAlert) {
            cancelAlert
        }
        .onChange(of: vm.inEditMode) { inEditMode in
            vm.vc?.navigationController?.interactivePopGestureRecognizer?.isEnabled = !inEditMode
        }
        .navigationTitle(vm.inEditMode ? "" : L10n.profileMyInfoRowTitle)
    }

    @ToolbarContentBuilder
    private var toolbars: some ToolbarContent {
        Group {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(L10n.myInfoCancelButton) {
                    vm.cancel()
                }
                .foregroundColor(hLabelColor.primary)
                .opacity(vm.inEditMode ? 1 : 0)
                .transition(.opacity.animation(.easeInOut(duration: 0.2)))
                .disabled(!vm.inEditMode)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                if vm.isLoading {
                    ProgressView().foregroundColor(hLabelColor.primary)
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
                    .foregroundColor(hLabelColor.primary)
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

class MyInfoViewModel: ObservableObject {
    @Inject var octopus: hOctopus
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
    private let bag = DisposeBag()
    init() {
        let store: ProfileStore = globalPresentableStoreContainer.get()
        originalPhone = store.state.memberPhone ?? ""
        originalEmail = store.state.memberEmail
        phone = store.state.memberPhone ?? ""
        email = store.state.memberEmail
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

    func save() async {
        await withCheckedContinuation { [weak self] continuation in
            guard let self = self else { return }
            let updatePhoneFuture = self.getPhoneFuture()
            let updateEmailFuture = self.getEmailFuture()
            join(updatePhoneFuture, updateEmailFuture)
                .onValue { _ in
                    DispatchQueue.main.async {
                        Toasts.shared.displayToast(
                            toast: Toast(
                                symbol: .icon(hCoreUIAssets.edit.image),
                                body: L10n.profileMyInfoSaveSuccessToastBody
                            )
                        )
                    }
                    continuation.resume()
                }
                .onError { error in
                    if let error = error as? MyInfoSaveError {
                        switch error {
                        case .emailEmpty, .emailMalformed:
                            DispatchQueue.main.async { [weak self] in
                                withAnimation {
                                    self?.emailError = error.localizedDescription
                                }
                            }
                        case .phoneNumberEmpty, .phoneNumberMalformed:
                            DispatchQueue.main.async { [weak self] in
                                withAnimation {
                                    self?.phoneError = error.localizedDescription
                                }
                            }
                        }
                    }
                    continuation.resume()
                }
        }
    }

    private func getPhoneFuture() -> Flow.Future<Void> {
        return Flow.Future<Void> { [weak self] completion in
            guard let self else { return NilDisposer() }
            if originalEmail != phone {
                if phone.isEmpty {
                    completion(.failure(MyInfoSaveError.phoneNumberEmpty))
                    return NilDisposer()
                }
                let innerBag = bag.innerBag()

                innerBag += self.octopus.client
                    .perform(
                        mutation: OctopusGraphQL.MemberUpdatePhoneNumberMutation(
                            input: OctopusGraphQL.MemberUpdatePhoneNumberInput(phoneNumber: phone)
                        )
                    )
                    .onValue { [weak self] data in
                        if let phoneNumber = data.memberUpdatePhoneNumber.member?.phoneNumber {
                            self?.originalPhone = phoneNumber
                            self?.store.send(.setMemberPhone(phone: phoneNumber))
                        }
                        completion(.success)
                    }
                    .onError { error in
                        completion(.failure(MyInfoSaveError.phoneNumberMalformed))
                    }

                return innerBag
            }
            completion(.success)
            return NilDisposer()
        }
    }

    private func getEmailFuture() -> Flow.Future<Void> {
        return Flow.Future<Void> { [weak self] completion in
            guard let self else { return NilDisposer() }
            if originalEmail != email {
                if email.isEmpty {
                    completion(.failure(MyInfoSaveError.emailEmpty))
                    return NilDisposer()
                }
                if !Masking(type: .email).isValid(text: email) {
                    completion(.failure(MyInfoSaveError.emailMalformed))
                    return NilDisposer()
                }
                let innerBag = bag.innerBag()

                innerBag += self.octopus.client
                    .perform(
                        mutation: OctopusGraphQL.MemberUpdateEmailMutation(
                            input: OctopusGraphQL.MemberUpdateEmailInput(email: email)
                        )
                    )
                    .onValue { [weak self] data in
                        if let email = data.memberUpdateEmail.member?.email {
                            self?.originalEmail = email
                            self?.store.send(.setMemberEmail(email: email))
                        }
                        completion(.success)

                    }
                    .onError { _ in
                        completion(.failure(MyInfoSaveError.emailMalformed))

                    }
                return innerBag
            }
            completion(.success)
            return NilDisposer()
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
        store.send(.setMember(id: "1", name: "Ma", email: "sladjann@gmail.com", phone: nil))
        return NavigationView {
            MyInfoView()
        }
    }
}

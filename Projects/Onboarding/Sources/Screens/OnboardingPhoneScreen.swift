import SwiftUI
import hCore
import hCoreUI

struct OnboardingPhoneScreen: View {
    let phoneNumber: String
    let email: String
    @EnvironmentObject var vm: OnboardingNavigationViewModel
    @StateObject private var phoneVm = OnboardingPhoneViewModel()
    let digits = [["1", "2", "3"], ["4", "5", "6"], ["7", "8", "9"], ["*", "0", "#"]]
    @State private var animateDigits: [String] = []
    var body: some View {
        hForm {
            hSection {
                VStack(spacing: .padding8) {
                    ForEach(digits, id: \.self) { row in
                        HStack(spacing: .padding10) {
                            ForEach(row, id: \.self) { digit in
                                hText(digit)
                                    .frame(width: 36, height: 36)
                                    .background(getColor(for: digit))
                                    .cornerRadius(.padding12)
                                    .scaleEffect(animateDigits.contains(digit) ? 1.2 : 1)
                                    .animation(.defaultSpring, value: animateDigits.contains(digit))
                                    .onTapGesture {
                                        if Int(digit) != nil {
                                            phoneVm.phone.append(digit)
                                        }
                                    }
                            }
                        }
                    }
                }
            }
            .sectionContainerStyle(.transparent)
        }
        .hFormTitle(
            title: .init(.small, .body1, "Phone number", alignment: .leading),
            subTitle: .init(
                .small,
                .body1,
                "Add your phone number so we can reach you if something happens",
                alignment: .leading
            )
        )
        .hFormContentPosition(.center)
        .hFormAttachToBottom {
            hSection {
                VStack(spacing: .padding8) {
                    hFloatingTextField(
                        masking: phoneVm.masking,
                        value: $phoneVm.phone,
                        equals: $phoneVm.focus,
                        focusValue: .phone,
                        placeholder: L10n.phoneNumberRowTitle,
                        error: $phoneVm.error
                    )

                    hSaveButton(.primary) {
                        if await phoneVm.save() {
                            UIApplication.dismissKeyboard()
                            vm.advance(after: .phoneNumber(phoneNumber: phoneNumber, email: email))
                        }
                    }
                    .hButtonIsLoading(phoneVm.isLoading)
                    hButton(.large, .ghost, content: .init(title: "Do this later")) {  // TODO: L10n
                        UIApplication.dismissKeyboard()
                        vm.advance(after: .phoneNumber(phoneNumber: phoneNumber, email: email))
                    }
                }
            }
            .sectionContainerStyle(.transparent)
        }
        .disabled(phoneVm.isLoading)
        .onAppear { phoneVm.prefill(phone: phoneNumber, email: email) }
        .onChange(of: phoneVm.phone) { value in
            if value.count < phoneVm.previousValue.count {
            } else {
                if let last = value.last {
                    animateDigits.append(String(last))
                }
                Task {
                    await delay(0.4)
                    animateDigits.removeFirst()
                }
            }
            phoneVm.previousValue = value
        }
    }

    @hColorBuilder
    private func getColor(for digit: String) -> some hColor {
        if animateDigits.contains(digit) {
            hSignalColor.Green.fill
        } else {
            hSurfaceColor.Translucent.secondary
        }
    }
}

private enum OnboardingPhoneField: hTextFieldFocusStateCompliant {
    case phone
    static let last: OnboardingPhoneField = .phone
    var next: OnboardingPhoneField? { nil }
}

@MainActor
class OnboardingPhoneViewModel: ObservableObject {
    private let service = OnboardingService()
    @Published var phone = ""
    var previousValue = ""
    @Published var isLoading = false
    @Published var error: String?
    let masking = Masking(type: .phoneNumber)
    @Published fileprivate var focus: OnboardingPhoneField?

    // NOTE: contact info arrives via the `.phoneNumber` step's payload (fetched once in
    // getOnboardingSteps); updateContactInfo takes email + phone and the screen passes
    // the existing email through unchanged (no caching in the client).
    private var email = ""

    func prefill(phone: String, email: String) {
        self.email = email
        if self.phone.isEmpty { self.phone = phone }
    }

    func save() async -> Bool {
        withAnimation {
            isLoading = true; error = nil
        }
        defer { withAnimation { isLoading = false } }
        do {
            try await service.updateContactInfo(email: email, phone: phone)
            return true
        } catch {
            self.error = error.localizedDescription
            return false
        }
    }
}

#Preview {
    OnboardingPhoneScreen(phoneNumber: "0735328847", email: "demo@hedvig.com")
        .environmentObject(OnboardingNavigationViewModel())
}

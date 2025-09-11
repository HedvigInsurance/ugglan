import SwiftUI
import hCore
import hCoreUI

struct ResendOTPCode: View {
    @StateObject private var vm = ResendOTPCodeViewModel()
    @ObservedObject var otpVM: OTPState

    var body: some View {
        Group {
            if vm.timeUntil(state: otpVM) >= 0 {
                SwiftUI.Button {
                    vm.resendCode(for: otpVM)
                } label: {
                    HStack(spacing: 8) {
                        hCoreUIAssets.refresh.view
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                            .rotationEffect(otpVM.isResending ? Angle(degrees: 0) : Angle(degrees: -360))
                            .animation(
                                otpVM.isResending ? .linear(duration: 1).repeatForever(autoreverses: false) : .default,
                                value: UUID()
                            )
                        hText(L10n.Login.SmediumButton.Active.resendCode, style: .label)
                    }
                }
                .tint(hTextColor.Opaque.primary)
            } else {
                hText(
                    vm.canResendAtText,
                    style: .label
                )
                .foregroundColor(hTextColor.Opaque.tertiary)
                .onReceive(vm.timer) { _ in
                    vm.updateText(state: otpVM)
                }
                .onAppear {
                    vm.updateText(state: otpVM)
                }
            }
        }
        .padding(.top, 44)
    }
}

@MainActor
class ResendOTPCodeViewModel: ObservableObject {
    private var authenticationService = AuthenticationService()
    @Published var canResendAtText: String = ""
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    func updateText(state: OTPState) {
        let timeUntil = abs(timeUntil(state: state))
        canResendAtText = L10n.Login.MediumButton.Inactive.resendCodeIn(timeUntil)
    }

    func timeUntil(state: OTPState) -> Int {
        guard let date = state.canResendAt else {
            return 0
        }

        return Int(Date().timeIntervalSince(date))
    }

    func resendCode(for otpState: OTPState) {
        Task { @MainActor [weak self, weak otpState] in
            otpState?.code = ""
            otpState?.codeErrorMessage = nil
            otpState?.isResending = true
            do {
                if let otpState {
                    try await self?.authenticationService.resend(otp: otpState)
                    otpState.code = ""
                    otpState.isLoading = false
                    otpState.codeErrorMessage = nil
                    otpState.otpInputErrorMessage = nil
                    otpState.canResendAt = Date().addingTimeInterval(60)
                    otpState.isResending = false
                    self?.showToast()
                }
            } catch {
                otpState?.codeErrorMessage = error.localizedDescription
            }
            otpState?.isResending = false
        }
    }

    private func showToast() {
        Toasts.shared.displayToastBar(
            toast: .init(
                type: .campaign,
                icon: hCoreUIAssets.refresh.view,
                text: L10n.Login.Snackbar.codeResent
            )
        )
    }
}

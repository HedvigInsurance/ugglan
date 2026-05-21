import Environment
import SwiftUI
import hCore
import hCoreUI

struct SwishPayinSetupScreen: View {
    @StateObject private var vm = SwishPayinSetupViewModel()
    @StateObject var router = NavigationRouter()
    let onSuccess: (() -> Void)?

    init(onSuccess: (() -> Void)? = nil) {
        self.onSuccess = onSuccess
    }

    var body: some View {
        hForm {
            if let successUrl = vm.successUrl {
                successContent(url: successUrl)
            } else {
                inputContent
            }
        }
        .hFormContentPosition(.compact)
        .hFormAttachToBottom {
            bottomContent
        }
        .disabled(vm.isLoading)
    }

    private var inputContent: some View {
        VStack(spacing: .padding4) {
            hSection {
                hFloatingTextField(
                    masking: .init(type: .phoneNumber),
                    value: $vm.phoneNumber,
                    equals: $vm.focusedField,
                    focusValue: .phoneNumber,
                    placeholder: L10n.phoneNumberRowTitle,
                    error: $vm.phoneNumberError
                )
            }
            .sectionContainerStyle(.transparent)
        }
    }

    private func successContent(url: URL) -> some View {
        VStack(spacing: .padding16) {
            VStack(spacing: .padding8) {
                hText("Process started")  //L10n.payinSwishSetupProcessStartedTitle
                    .multilineTextAlignment(.center)
                hText("Open Swish to complete the setup", style: .label)  //L10n.payinSwishSetupProcessStartedSubtitle
                    .foregroundColor(hTextColor.Translucent.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, .padding16)
            QRCodeView(token: url.absoluteString)
                .frame(width: 180, height: 180)
        }
        .padding(.top, .padding16)
    }

    @ViewBuilder
    private var bottomContent: some View {
        if let successUrl = vm.successUrl {
            openSwishButton(url: successUrl)
        } else {
            inputBottomContent
        }
    }

    private var inputBottomContent: some View {
        hSection {
            if let errorMessage = vm.errorMessage {
                errorView(message: errorMessage)
            }
            saveButton
        }
        .padding(.vertical, .padding16)
        .sectionContainerStyle(.transparent)
    }

    private func errorView(message: String) -> some View {
        HStack {
            Image(uiImage: hCoreUIAssets.warningTriangleFilled.image)
                .foregroundColor(hSignalColor.Red.element)
            hText(message, style: .label)
                .foregroundColor(hSignalColor.Red.text)
        }
        .padding(.bottom, .padding8)
    }

    private var saveButton: some View {
        hButton(
            .large,
            .primary,
            content: .init(title: L10n.generalSaveButton)
        ) { [weak vm] in
            Task { await vm?.save() }
        }
        .hButtonIsLoading(vm.isLoading)
    }

    private func openSwishButton(url: URL) -> some View {
        hSection {
            hButton(
                .large,
                .primary,
                content: .init(title: "Open Swish"),  //L10n.payinSwishSetupOpenSwishButton
                { [onSuccess] in
                    let urlOpener: URLOpener = Dependencies.shared.resolve()
                    urlOpener.open(url)
                    onSuccess?()
                }
            )
        }
        .padding(.vertical, .padding16)
        .sectionContainerStyle(.transparent)
    }
}

extension SwishPayinSetupScreen: TrackingViewNameProtocol {
    var nameForTracking: String {
        .init(describing: SwishPayinSetupScreen.self)
    }
}

@MainActor
class SwishPayinSetupViewModel: ObservableObject {
    @Published var phoneNumber: String = ""
    @Published var focusedField: SwishPayinField?
    @Published var phoneNumberError: String?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var successUrl: URL?

    private let paymentService = hPaymentService()
    private let phoneNumberMasking = Masking(type: .phoneNumber)

    func save() async {
        withAnimation {
            phoneNumberError = nil
            errorMessage = nil
        }

        if !validate() { return }

        withAnimation { isLoading = true }
        defer { withAnimation { isLoading = false } }

        do {
            let result = try await paymentService.setupPaymentMethod(
                .swishPayin(
                    phoneNumber: phoneNumberMasking.unmaskedValue(text: phoneNumber)
                )
            )
            if let errorMessage = result.errorMessage {
                withAnimation { self.errorMessage = errorMessage }
                return
            }
            guard let urlToOpen = result.url, var components = URLComponents(string: urlToOpen) else {
                return
            }
            var queryItems = components.queryItems ?? []
            queryItems.append(
                URLQueryItem(name: "ret", value: Environment.current.deepLinkUrl.absoluteString)
            )
            components.queryItems = queryItems
            guard let url = components.url else { return }
            withAnimation { self.successUrl = url }
        } catch {
            withAnimation { errorMessage = error.localizedDescription }
        }
    }

    private func validate() -> Bool {
        guard phoneNumberMasking.isValid(text: phoneNumber) else {
            withAnimation {
                phoneNumberError = L10n.myInfoPhoneNumberMalformedError
                focusedField = .phoneNumber
            }
            return false
        }
        return true
    }
}

enum SwishPayinField: hTextFieldFocusStateCompliant {
    case phoneNumber

    static var last: SwishPayinField { .phoneNumber }

    var next: SwishPayinField? {
        switch self {
        case .phoneNumber: return nil
        }
    }
}

#Preview {
    SwishPayinSetupScreen()
        .environmentObject(NavigationRouter())
}

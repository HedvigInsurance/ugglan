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
            VStack(spacing: .padding4) {
                phoneNumberField
            }
        }
        .hFormContentPosition(.compact)
        .hFormAttachToBottom {
            bottomContent
        }
        .disabled(vm.isLoading)
    }

    private var phoneNumberField: some View {
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

    private var bottomContent: some View {
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
        ) { [weak vm, onSuccess] in
            Task {
                if let url = await vm?.save() {
                    let urlOpener: URLOpener = Dependencies.shared.resolve()
                    urlOpener.open(url)
                    onSuccess?()
                }
            }
        }
        .hButtonIsLoading(vm.isLoading)
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

    private let paymentService = hPaymentService()
    private let phoneNumberMasking = Masking(type: .phoneNumber)

    func save() async -> URL? {
        withAnimation {
            phoneNumberError = nil
            errorMessage = nil
        }

        if !validate() { return nil }

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
                return nil
            }
            guard let urlToOpen = result.url, var components = URLComponents(string: urlToOpen) else {
                return nil
            }
            var queryItems = components.queryItems ?? []
            queryItems.append(
                URLQueryItem(name: "ret", value: Environment.current.deepLinkUrl.absoluteString)
            )
            components.queryItems = queryItems
            return components.url
        } catch {
            withAnimation { errorMessage = error.localizedDescription }
            return nil
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

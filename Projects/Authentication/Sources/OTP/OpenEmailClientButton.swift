import Foundation
import SwiftUI
import hCore
import hCoreUI

struct EmailClient {
    var url: URL?
    var displayName: String

    var isInstalled: Bool {
        guard let url = url else {
            return false
        }

        return UIApplication.shared.canOpenURL(url)
    }

    func open() {
        guard isInstalled == true, let url = url else {
            return
        }

        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}

public struct EmailOptions {
    let recipient: String?
    let subject: String?
    let body: String?

    public init(
        recipient: String? = nil,
        subject: String? = nil,
        body: String? = nil
    ) {
        self.recipient = recipient
        self.subject = subject
        self.body = body
    }
}

public enum OpenEmailButtonType {
    case secondary
    case primary
}

public struct OpenEmailClientButton: View {
    @State var sheetPresented: Bool = false
    let options: EmailOptions?
    let buttonText: String?
    var hasPressedButton: (() -> Void)?
    @Binding var hasAcceptedAlert: Bool
    let buttonSize: OpenEmailButtonType

    public init(
        options: EmailOptions? = nil,
        buttonText: String? = nil,
        hasAcceptedAlert: Binding<Bool>? = nil,
        hasPressedButton: (() -> Void)? = nil,
        buttonSize: OpenEmailButtonType? = .primary
    ) {
        self.options = options
        self.buttonText = buttonText
        self._hasAcceptedAlert = hasAcceptedAlert ?? .constant(true)
        self.hasPressedButton = hasPressedButton
        self.buttonSize = buttonSize ?? .primary

        emailClients = {
            let appleURLString = addEmailUrlComponents(baseUrl: "mailto:?")
            let gmailURLString = addEmailUrlComponents(baseUrl: "googlegmail:///co?")
            let outlookURLString = addEmailUrlComponents(baseUrl: "ms-outlook://compose?")

            return [
                EmailClient(url: URL(string: appleURLString), displayName: "Apple Mail"),
                EmailClient(url: URL(string: gmailURLString), displayName: "Gmail"),
                EmailClient(url: URL(string: outlookURLString), displayName: "Outlook"),
            ]
        }()
    }

    func addEmailUrlComponents(baseUrl: String) -> String {
        var fullUrl = baseUrl

        if let receipient = options?.recipient {
            fullUrl.append("&to=" + receipient)
        }
        if let subject = options?.subject {
            fullUrl.append("&subject=" + subject)
        }
        if let body = options?.body {
            fullUrl.append("&body=" + body)
        }
        return fullUrl
    }

    var emailClients: [EmailClient] = []

    func showButton(state: OTPState) -> Bool {
        !sheetPresented && state.code.isEmpty
    }

    public var body: some View {
        ReadOTPState { state in
            hSection {
                displayButton
            }
            .offset(x: 0, y: showButton(state: state) ? 0 : 150)
            .opacity(showButton(state: state) ? 1 : 0)
            .animation(.spring(), value: showButton(state: state))
        }
        .onUpdate(
            of: hasAcceptedAlert,
            perform: { newValue in
                sheetPresented = true
            }
        )
        .actionSheet(isPresented: $sheetPresented) {
            ActionSheet(
                title: Text(L10n.Login.openEmailAppButton),
                buttons: [
                    emailClients.compactMap { $0.isInstalled ? $0 : nil }
                        .map { emailClient in
                            .default(Text(emailClient.displayName)) { emailClient.open() }
                        },
                    [.cancel()],
                ]
                .flatMap { $0 }
            )
        }
    }

    @ViewBuilder
    public var displayButton: some View {
        switch buttonSize {
        case .secondary:
            hButton.LargeButton(type: .secondary) {
                if hasAcceptedAlert {
                    sheetPresented = true
                } else {
                    hasPressedButton?()
                }
            } content: {
                hText(buttonText ?? L10n.Login.openEmailAppButton)
            }
        //            .fixedSize()
        case .primary:
            hButton.LargeButton(type: .primary) {
                if hasAcceptedAlert {
                    sheetPresented = true
                } else {
                    hasPressedButton?()
                }
            } content: {
                hText(buttonText ?? L10n.Login.openEmailAppButton)
            }
        }
    }
}

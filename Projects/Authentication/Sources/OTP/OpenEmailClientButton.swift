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

struct OpenEmailClientButton: View {
    @State var sheetPresented: Bool = false

    var emailClients = [
        EmailClient(url: URL(string: "message://"), displayName: "Apple Mail"),
        EmailClient(url: URL(string: "googlegmail://"), displayName: "Gmail"),
        EmailClient(url: URL(string: "ms-outlook://"), displayName: "Outlook"),
    ]

    func showButton(state: OTPState) -> Bool {
        !sheetPresented && state.code.isEmpty
    }

    var body: some View {
        ReadOTPState { state in
            hSection {
                hButton.LargeButtonFilled {
                    sheetPresented = true
                } content: {
                    hText(L10n.Login.openEmailAppButton)
                }
            }
            .offset(x: 0, y: showButton(state: state) ? 0 : 150)
            .opacity(showButton(state: state) ? 1 : 0)
            .animation(.spring(), value: showButton(state: state))
        }
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
}

import SwiftUI
import hCore

/// Opens the BankID app on this device.
@MainActor
public enum BankIDApp {
    public static var isInstalled: Bool {
        guard let url = URL(string: "bankid:///") else { return false }
        return UIApplication.shared.canOpenURL(url)
    }

    /// Starts the order `autoStartToken` belongs to in the BankID app, which returns to this app when done.
    public static func open(autoStartToken: String) {
        let urlScheme = Bundle.main.urlScheme ?? ""
        guard
            let url = URL(string: "bankid:///?autostarttoken=\(autoStartToken)&redirect=\(urlScheme)://bankid"),
            UIApplication.shared.canOpenURL(url)
        else { return }
        log.info("BANK ID APP started", error: nil, attributes: nil)
        Task { await Dependencies.urlOpener.open(url) }
    }
}

/// A BankID QR code. Identified by its data, so a view can animate from one code to the next.
public struct BankIDQRCode: Equatable, Identifiable {
    public let id: String
    public let image: UIImage

    /// The animated code data from the backend (changes every second).
    public init?(data: String) {
        guard let image = StyledQRCode.image(for: data, logoFraction: 0, correctionLevel: .low) else { return nil }
        self.id = data
        self.image = image
    }

    /// The static code for an order, used until the first animated code arrives.
    public init?(autoStartToken: String) {
        self.init(data: "bankid:///?autostarttoken=\(autoStartToken)")
    }
}

/// Always drawn dark-on-light, the way scanners expect a code. In dark mode it sits on a light card matching the
/// form's light background, which also gives the code its quiet zone.
public struct BankIDQRCodeView: View {
    let qrCode: BankIDQRCode
    @SwiftUI.Environment(\.colorScheme) private var colorScheme

    public init(qrCode: BankIDQRCode) {
        self.qrCode = qrCode
    }

    public var body: some View {
        StyledQRCodeView(image: qrCode.image)
            .frame(width: 180, height: 180)
            .padding(colorScheme == .dark ? .padding16 : 0)
            .background {
                if colorScheme == .dark {
                    RoundedRectangle(cornerRadius: .cornerRadiusXL)
                        .fill(hBackgroundColor.primary)
                }
            }
            .colorScheme(.light)
            .transition(.opacity)
            .id(qrCode.id)
    }
}

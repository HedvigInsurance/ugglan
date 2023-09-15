import Presentation
import SwiftUI
import hCore
import hCoreUI

class BandIDViewModel: ObservableObject {
    @Published var showAlert: Bool = false
}

public struct BankIDLoginQR: View {
    @PresentableStore var store: AuthenticationStore
    @State var image: UIImage?
    @StateObject var vm = BandIDViewModel()

    public init() {
        store.send(.seBankIDStateAction(action: .startSession))
        let bankIdAppTestUrl = URL(
            string:
                "bankid:///"
        )!

        if UIApplication.shared.canOpenURL(bankIdAppTestUrl) {
            store.send(.openBankIdApp)
        }
    }

    public var body: some View {
        hForm {
            VStack(spacing: 32) {
                PresentableStoreLens(
                    AuthenticationStore.self,
                    getter: { state in
                        state.seBankIDState.bankIdQRCodeString
                    }
                ) { qrCode in
                    if let qrCode = qrCode {
                        let _ = generateQRCode(qrCode)
                    }
                }

                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 140)
                        .foregroundColor(hTextColorNew.primary)
                        .transition(.scale)
                        .alert(isPresented: $vm.showAlert) {
                            Alert(
                                title: Text(L10n.demoModeStart),
                                message: nil,
                                primaryButton: .cancel(Text(L10n.demoModeCancel)),
                                secondaryButton: .destructive(Text(L10n.logoutAlertActionConfirm)) {
                                    store.send(.cancel)
                                    ApplicationContext.shared.$isDemoMode.value = true
                                    store.send(.bankIdQrResultAction(action: .loggedIn))
                                }
                            )
                        }
                        .onLongPressGesture(minimumDuration: 3.0) {
                            vm.showAlert = true
                        }
                }

                VStack(spacing: 0) {
                    hText(L10n.authenticationBankidLoginTitle)
                        .foregroundColor(hTextColorNew.primaryTranslucent)
                    hText(L10n.authenticationBankidLoginLabel)
                        .foregroundColor(hTextColorNew.secondaryTranslucent)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 16)

                Image(uiImage: hCoreUIAssets.menuIcon.image)
                    .frame(height: 6)
            }
            .padding(.top, UIScreen.main.bounds.size.height / 5.0)
        }
        .hDisableScroll
        .hFormAttachToBottom {
            VStack(spacing: 16) {
                let bankIdAppTestUrl = URL(
                    string:
                        "bankid:///"
                )!

                if UIApplication.shared.canOpenURL(bankIdAppTestUrl) {
                    hButton.LargeButton(type: .primary) {
                        store.send(.seBankIDStateAction(action: .startSession))
                        store.send(.openBankIdApp)
                    } content: {
                        HStack(spacing: 8) {
                            Image(uiImage: hCoreUIAssets.bankIdSmall.image)
                            hText(L10n.authenticationBankidOpenButton)
                        }
                    }
                }

                hButton.LargeButton(type: .ghost) {
                    store.send(.bankIdQrResultAction(action: .emailLogin))
                } content: {
                    hText(L10n.BankidMissingLogin.emailButton)
                }
            }
            .padding(.bottom, 32)
            .padding(.horizontal, 16)
        }
    }

    func generateQRCode(_ url: URL) {
        let data = url.absoluteString.data(using: String.Encoding.ascii)
        guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else { return }
        qrFilter.setValue(data, forKey: "inputMessage")
        guard let qrImage = qrFilter.outputImage else { return }

        let transform = CGAffineTransform(scaleX: 10, y: 10)
        let scaledQrImage = qrImage.transformed(by: transform)

        guard let maskToAlphaFilter = CIFilter(name: "CIMaskToAlpha") else { return }
        maskToAlphaFilter.setValue(scaledQrImage, forKey: "inputImage")
        guard let outputCIImage = maskToAlphaFilter.outputImage else { return }

        let context = CIContext()
        guard let cgImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) else {
            return
        }
        let processedImage = UIImage(cgImage: cgImage).withRenderingMode(.alwaysTemplate)

        DispatchQueue.main.async {
            image = processedImage
        }
    }
}

struct BankIDLoginQR_Previews: PreviewProvider {
    static var previews: some View {
        BankIDLoginQR()
    }
}

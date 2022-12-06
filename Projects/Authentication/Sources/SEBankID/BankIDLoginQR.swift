import Flow
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI

public struct BankIDLoginQR {
    @PresentableStore var store: AuthenticationStore
    
    public init() {}
}

public enum BankIDLoginQRResult {
    case loggedIn
    case emailLogin
}

extension BankIDLoginQR: Presentable {
    public func materialize() -> (UIViewController, Signal<BankIDLoginQRResult>) {
        let viewController = UIViewController()
        let bag = DisposeBag()

        let view = UIView()
        view.backgroundColor = .brand(.primaryBackground())

        viewController.view = view
        viewController.title = L10n.bankidMissingTitle
        viewController.navigationItem.hidesBackButton = true

        let moreBarButtonItem = UIBarButtonItem(
            image: hCoreUIAssets.menuIcon.image,
            style: .plain,
            target: nil,
            action: nil
        )
        moreBarButtonItem.tintColor = .brand(.primaryText())

        viewController.navigationItem.rightBarButtonItem = moreBarButtonItem

        let containerStackView = UIStackView()
        containerStackView.spacing = 28
        containerStackView.axis = .vertical
        containerStackView.alignment = .center
        containerStackView.layoutMargins = UIEdgeInsets(horizontalInset: 16, verticalInset: 24)
        containerStackView.isLayoutMarginsRelativeArrangement = true

        view.addSubview(containerStackView)

        containerStackView.snp.makeConstraints { make in make.leading.trailing.top.equalToSuperview() }

        let headerContainer = UIStackView()
        headerContainer.axis = .vertical
        headerContainer.spacing = 15

        containerStackView.addArrangedSubview(headerContainer)

        let iconContainerView = UIView()

        iconContainerView.snp.makeConstraints { make in make.height.width.equalTo(128) }

        let imageView = UIImageView()

        iconContainerView.addSubview(imageView)

        imageView.snp.makeConstraints { make in make.height.width.equalToSuperview() }

        headerContainer.addArrangedSubview(iconContainerView)

        let messageLabel = MultilineLabel(
            value: L10n.bankidMissingMessageGenAuth,
            style: .brand(.headline(color: .primary))
        )
        bag += containerStackView.addArranged(messageLabel)

        let emailLoginButton = Button(
            title: L10n.BankidMissingLogin.emailButton,
            type: .standardOutline(
                borderColor: .brand(.primaryText()),
                textColor: .brand(.primaryText())
            )
        )
        bag += containerStackView.addArranged(emailLoginButton)

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
            let processedImage = UIImage(cgImage: cgImage)

            imageView.tintColor = .brand(.primaryText())
            imageView.backgroundColor = UIColor.brand(.secondaryBackground())
            imageView.image = processedImage.withRenderingMode(.alwaysTemplate)
        }
        
        bag += viewController.view.windowSignal.onValueDisposePrevious { window in
            if window != nil {
                return Signal(every: 75)
                    .atOnce().onValue { _ in
                        store.send(.seBankIDStateAction(action: .startSession))
                    }
            } else {
                return Signal(after: 0).onValue { _ in
                    store.send(.cancel)
                }
            }
        }
                
        bag += store.stateSignal.compactMap({ state in
            state.seBankIDState.autoStartToken
        }).onValue({ autoStartToken in
            guard
                let url = URL(
                    string:
                        "bankid:///?autostarttoken=\(autoStartToken)"
                )
            else {
                UIView.transition(with: imageView, duration: 0.5, options: [.transitionCrossDissolve]) {
                    imageView.image = nil
                }
                return
            }
            
            UIView.transition(with: imageView, duration: 0.5, options: [.transitionCrossDissolve]) {
                generateQRCode(url)
            }
        })

        return (
            viewController,
            Signal { callback in
                bag += store.onAction(.navigationAction(action: .authSuccess), {
                    callback(.loggedIn)
                })
                
                bag += moreBarButtonItem.onValue { _ in
                    let alert = Alert<Void>(actions: [
                        .init(
                            title: L10n.demoModeStart,
                            action: {
                                callback(.loggedIn)
                            }
                        ), .init(title: L10n.demoModeCancel, style: .cancel, action: {}),
                    ])

                    viewController.present(
                        alert,
                        style: .sheet(
                            from: moreBarButtonItem.view,
                            rect: moreBarButtonItem.view?.frame
                        )
                    )
                }

                bag += emailLoginButton.onTapSignal.onValue { _ in
                    callback(.emailLogin)
                }

                return bag
            }
        )
    }
}

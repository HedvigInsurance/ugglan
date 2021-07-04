#if canImport(Adyen)

import Adyen
import AdyenCard
import Apollo
import Flow
import Form
import Foundation
import Kingfisher
import Presentation
import UIKit
import hCore
import hCoreUI
import hGraphQL

struct AdyenMethodsList {
	typealias DidSubmit = (
		_ data: PaymentComponentData, _ component: PaymentComponent,
		_ onResult: @escaping (_ result: Flow.Result<Either<Void, Adyen.Action>>) -> Void
	) -> Void

	let adyenOptions: AdyenOptions
	let didSubmit: DidSubmit
	let onSuccess: () -> Void
}

extension AdyenMethodsList: Presentable {
	func materialize() -> (UIViewController, Future<Void>) {
		let viewController = UIViewController()
		viewController.navigationItem.hidesBackButton = true

		let bag = DisposeBag()

		let form = FormView()

		let section = form.appendSection()

		bag += viewController.install(form)

		return (
			viewController,
			Future { completion in
				bag += adyenOptions.paymentMethods.regular.map { method in
					let row = RowView(title: method.displayInformation.title)

					let logoImageView = UIImageView()
					logoImageView.contentMode = .scaleAspectFit

					let logoURL = Adyen.LogoURLProvider.logoURL(
						for: method,
						environment: AdyenPaymentBuilder.environment
					)
					logoImageView.kf.setImage(with: logoURL)

					logoImageView.snp.makeConstraints { make in make.width.equalTo(30)
						make.height.equalTo(30)
					}

					row.prepend(logoImageView)
					row.append(hCoreUIAssets.chevronRight.image)

					return section.append(row)
						.onValue {
							guard
								let component = method.buildComponent(
									using: AdyenPaymentBuilder(
										encryptionPublicKey: adyenOptions
											.clientEncrytionKey
									)
								)
							else { return }

							let delegate = PaymentDelegate(
								viewController: viewController,
								paymentMethod: method,
								didSubmitHandler: didSubmit
							) {
								completion(.success)
							} onRetry: {
								viewController.present(
									self.wrappedInCloseButton(),
									configure: { vc, _ in
										vc.title = viewController.title
									}
								)
								.onValue { completion(.success) }
								.onError { error in completion(.failure(error)) }
							} onSuccess: {
								self.onSuccess()
							}
							bag.hold(delegate)
							bag.hold(component)

							component.delegate = delegate

							switch component {
							case let component as PresentableComponent:
								let excepted =
									(component.viewController is UIAlertController)
									|| (component is ApplePayComponent)

								if excepted {
									viewController.present(
										component.viewController,
										animated: true
									)
								} else {
									viewController.present(
										component.viewController,
										style: .detented(.large, modally: false)
									)
								}
							case let component as EmptyPaymentComponent:
								component.initiatePayment()
							default: fatalError("Adyen payment option not implemented")
							}
						}
				}

				return bag
			}
		)
	}
}

#endif

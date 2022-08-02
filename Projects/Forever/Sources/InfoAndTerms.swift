import Flow
import Foundation
import Presentation
import SafariServices
import SwiftUI
import UIKit
import hCore
import hCoreUI
import hGraphQL

public struct InfoAndTermsView: View {
    @PresentableStore var store: ForeverStore
    @State var potentialDiscount: String

    public var body: some View {
        hForm {
            hSection {
                VStack(spacing: 16) {
                    Image(uiImage: Asset.infoAndTermsIllustration.image)
                    L10n.ReferralsInfoSheet.headline.hText(.title1)
                    L10n.ReferralsInfoSheet.body(potentialDiscount).hText().foregroundColor(hLabelColor.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .sectionContainerStyle(.transparent).padding(.top, 16)
        }
        .hFormAttachToBottom {
            hButton.LargeButtonFilled {
                UIApplication.shared.open(URL(string: L10n.referralsTermsWebsiteUrl)!)
            } content: {
                L10n.ReferralsInfoSheet.fullTermsAndConditions.hText()
            }
            .padding()
        }
        .navigationBarItems(
            trailing: Button(action: {
                store.send(.closeInfoSheet)
            }) {
                L10n.NavBar.close.hText().foregroundColor(hLabelColor.link)
            }
        )
    }
}

public struct InfoAndTerms {
    let potentialDiscountAmountSignal: ReadSignal<MonetaryAmount?>

    public init(
        potentialDiscountAmountSignal: ReadSignal<MonetaryAmount?>
    ) { self.potentialDiscountAmountSignal = potentialDiscountAmountSignal }
}

extension InfoAndTerms: Presentable {
    public func materialize() -> (UIViewController, Future<Void>) {
        let viewController = UIViewController()
        let bag = DisposeBag()

        let closeBarButton = UIBarButtonItem(title: L10n.NavBar.close)
        viewController.navigationItem.rightBarButtonItem = closeBarButton

        var imageTextAction = ImageTextAction<Void>(
            image: .init(image: Asset.infoAndTermsIllustration.image),
            title: L10n.ReferralsInfoSheet.headline,
            body: "",
            actions: [
                (
                    (),
                    Button(
                        title: L10n.ReferralsInfoSheet.fullTermsAndConditions,
                        type: .standard(
                            backgroundColor: .brand(.primaryButtonBackgroundColor),
                            textColor: .brand(.primaryButtonTextColor)
                        )
                    )
                )
            ],
            showLogo: false
        )

        bag += potentialDiscountAmountSignal.atOnce().compactMap { $0 }
            .map { L10n.ReferralsInfoSheet.body($0.formattedAmount) }
            .onValue { body in imageTextAction.body = body }

        return (
            viewController,
            Future { completion in
                bag += viewController.install(imageTextAction)
                    .onValue {
                        viewController.present(
                            SFSafariViewController(
                                url: URL(string: L10n.referralsTermsWebsiteUrl)!
                            ),
                            animated: true,
                            completion: nil
                        )
                    }

                bag += closeBarButton.onValue { completion(.success) }

                return DelayedDisposer(bag, delay: 2)
            }
        )
    }
}

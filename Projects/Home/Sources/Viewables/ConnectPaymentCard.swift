import Apollo
import Flow
import Foundation
import Presentation
import SnapKit
import UIKit
import hCore
import hCoreUI
import hGraphQL

struct ConnectPaymentCard { @Inject var client: ApolloClient }

extension ConnectPaymentCard: Presentable {
    func materialize() -> (UIStackView, Disposable) {
        let bag = DisposeBag()
        let stackView = UIStackView()
        stackView.axis = .vertical

        func animateIn(_ view: UIView) {
            view.isHidden = true

            bag += Animated.now.animated(style: SpringAnimationStyle.lightBounce()) { _ in
                view.isHidden = false
            }
        }

        bag += client.watch(query: GraphQL.PayInMethodStatusQuery()).map { $0.payinMethodStatus }.distinct()
            .onValueDisposePrevious { status -> Disposable? in let bag = DisposeBag()

                if status == .needsSetup {
                    let store: HomeStore = self.get()

                    bag += stackView.addArranged(Spacing(height: 56), onCreate: animateIn)
                    bag +=
                        stackView.addArranged(
                            Card(
                                titleIcon: hCoreUIAssets.warningTriangle.image,
                                title: L10n.InfoCardMissingPayment.title,
                                body: L10n.InfoCardMissingPayment.body,
                                buttonText: L10n.InfoCardMissingPayment.buttonText,
                                backgroundColor: .tint(.yellowOne),
                                buttonType: .standardSmall(
                                    backgroundColor: .tint(.yellowTwo),
                                    textColor: .typographyColor(
                                        .primary(
                                            state: .matching(
                                                .tint(.yellowTwo)
                                            )
                                        )
                                    )
                                )
                            ),
                            onCreate: animateIn
                        )
                        .compactMap { _ in stackView.viewController }
                        .onValue { viewController in
                            store.send(.connectPayments)
                        }
                }

                return bag
            }

        return (stackView, bag)
    }
}

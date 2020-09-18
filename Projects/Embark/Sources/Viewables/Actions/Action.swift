import Flow
import Foundation
import hCore
import hCoreUI
import hGraphQL
import UIKit

struct Action {
    let state: EmbarkState
}

struct ActionResponse {
    let link: GraphQL.EmbarkLinkFragment
    let data: ActionResponseData
}

struct ActionResponseData {
    let keys: [String]
    let values: [String]
    let textValue: String
}

extension Action: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Signal<GraphQL.EmbarkLinkFragment>) {
        let view = UIStackView()
        view.axis = .vertical

        let bag = DisposeBag()

        let backButton = Button(
            title: L10n.embarkGoBackButton,
            type: .standardSmall(backgroundColor: .brand(.secondaryBackground()), textColor: .brand(.primaryText()))
        )
        bag += backButton.onTapSignal.onValue {
            self.state.goBack()
        }

        bag += view.addArranged(backButton.wrappedIn(UIStackView())) { buttonView in
            buttonView.axis = .vertical
            buttonView.alignment = .center
            buttonView.distribution = .equalCentering
            bag += self.state.canGoBackSignal.delay(by: 0.25).atOnce().map { !$0 }.bindTo(buttonView, \.isHidden)
        }

        let spacing = Spacing(height: 12)
        bag += view.addArranged(spacing)

        let actionDataSignal = state.currentPassageSignal.map { $0?.action }

        let isHiddenSignal = ReadWriteSignal(true)

        func handleViewState(_ isHidden: Bool) {
            let extraPadding: CGFloat = 40
            let viewHeight = view.systemLayoutSizeFitting(.zero).height + (view.superview?.safeAreaInsets.bottom ?? 0) + backButton.type.value.height + extraPadding
            view.transform = isHidden ? CGAffineTransform(translationX: 0, y: viewHeight) : CGAffineTransform.identity
        }

        bag += view.didLayoutSignal.withLatestFrom(isHiddenSignal.atOnce().plain()).map { _, isHidden in isHidden }.onValue(handleViewState)
        bag += isHiddenSignal.atOnce().onValue(handleViewState)

        let animationStyle = SpringAnimationStyle(
            duration: 0.5,
            damping: 100,
            velocity: 0.8,
            delay: 0,
            options: [.allowUserInteraction]
        )

        let hideAnimationSignal = actionDataSignal.withLatestFrom(state.passageNameSignal).animated(style: animationStyle) { _, _ in
            isHiddenSignal.value = true
            view.layoutIfNeeded()
        }.delay(by: 0)

        bag += hideAnimationSignal.delay(by: 0.25).animated(style: animationStyle) { _ in
            isHiddenSignal.value = false
            view.layoutIfNeeded()
        }

        return (view, Signal { callback in
            let shouldUpdateUISignal = actionDataSignal.flatMapLatest { _ in hideAnimationSignal.map { _ in true }.readable(initial: false) }

            bag += actionDataSignal.withLatestFrom(self.state.passageNameSignal).wait(until: shouldUpdateUISignal).onValueDisposePrevious { actionData, _ in
                let innerBag = DisposeBag()

                if let selectAction = actionData?.asEmbarkSelectAction {
                    innerBag += view.addArranged(EmbarkSelectAction(
                        state: self.state,
                        data: selectAction
                    )).onValue(callback)
                } else if let textAction = actionData?.asEmbarkTextAction {
                    innerBag += view.addArranged(EmbarkTextAction(
                        state: self.state,
                        data: textAction
                    )).onValue(callback)
                } else if let numberAction = actionData?.asEmbarkNumberAction {
                    innerBag += view.addArranged(EmbarkNumberAction(
                        state: self.state,
                        data: numberAction
                    )).onValue(callback)
                } else if let textActionSet = actionData?.asEmbarkTextActionSet {
                    innerBag += view.addArranged(TextActionSet(
                        state: self.state,
                        data: textActionSet
                    )).onValue(callback)
                } else if let externalInsuranceProviderAction = actionData?.asEmbarkExternalInsuranceProviderAction {
                    innerBag += view.addArranged(InsuranceProviderAction(
                        state: self.state,
                        data: externalInsuranceProviderAction
                    )).onValue(callback)
                }

                return innerBag
            }

            return bag
        })
    }
}

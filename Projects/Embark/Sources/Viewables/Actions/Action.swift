import Flow
import Foundation
import SwiftUI
import UIKit
import hCore
import hCoreUI
import hGraphQL
import hAnalytics

struct Action { let state: EmbarkState }

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
        let bag = DisposeBag()

        let outerContainer = UIStackView()
        outerContainer.axis = .vertical
        outerContainer.alignment = .center

        bag += state.edgePanGestureRecognizer?.signal(forState: .changed)
            .onValue { _ in
                guard let viewController = outerContainer.viewController,
                    let edgePanGestureRecognizer = state.edgePanGestureRecognizer
                else { return }

                let percentage =
                    edgePanGestureRecognizer.translation(in: viewController.view).x
                    / viewController.view.frame.width

                outerContainer.transform = CGAffineTransform(
                    translationX: 0,
                    y: outerContainer.frame.height * (percentage * 2.5)
                )
            }

        bag += state.edgePanGestureRecognizer?.signal(forState: .ended)
            .animated(style: .heavyBounce()) {
                outerContainer.transform = CGAffineTransform(translationX: 0, y: 0)
            }

        let widthContainer = UIStackView()
        widthContainer.axis = .horizontal
        outerContainer.addArrangedSubview(widthContainer)

        bag += outerContainer.didLayoutSignal.onValue { _ in
            widthContainer.snp.remakeConstraints { make in
                if outerContainer.traitCollection.horizontalSizeClass == .regular,
                    outerContainer.traitCollection.userInterfaceIdiom == .pad
                {
                    make.width.equalTo(
                        outerContainer.frame.width > 600 ? 600 : outerContainer.frame.width
                    )
                } else {
                    make.width.equalTo(outerContainer.frame.width)
                }
            }
        }

        let view = UIStackView()
        view.axis = .horizontal
        widthContainer.addArrangedSubview(view)

        let actionDataSignal = state.currentPassageSignal.map { $0?.action }

        let isHiddenSignal = ReadWriteSignal(true)

        func handleViewState(_ isHidden: Bool) {
            let extraPadding: CGFloat = 40
            let viewHeight =
                view.systemLayoutSizeFitting(.zero).height
                + (view.viewController?.view.safeAreaInsets.bottom ?? 0) + extraPadding

            let staticHeight =
                view.frame.height + (view.viewController?.view.safeAreaInsets.bottom ?? 0)
                + extraPadding
            let heightToTranslate = max(viewHeight, staticHeight)

            view.transform =
                isHidden
                ? CGAffineTransform(translationX: 0, y: heightToTranslate) : CGAffineTransform.identity
        }

        bag += view.didLayoutSignal.withLatestFrom(isHiddenSignal.atOnce().plain())
            .map { _, isHidden in isHidden }.onValue(handleViewState)
        bag += isHiddenSignal.atOnce().onValue(handleViewState)

        let animationStyle = SpringAnimationStyle(
            duration: 0.5,
            damping: 100,
            velocity: 0.8,
            delay: 0,
            options: [.allowUserInteraction]
        )

        let updateViewsCallbacker = Callbacker<Void>()

        let hideAnimationSignal = actionDataSignal.withLatestFrom(state.passageNameSignal)
            .animated(style: animationStyle) { _, _ in
                isHiddenSignal.value = true
                view.firstPossibleResponder?.resignFirstResponder()
                view.layoutIfNeeded()
            }
            .delay(by: 0)

        bag += hideAnimationSignal.delay(by: 0.25)
            .wait(until: state.isApiLoadingSignal.map { !$0 })
            .animated(style: animationStyle) { _ in
                isHiddenSignal.value = false
                view.layoutIfNeeded()
            }
            .atValue { _ in
                updateViewsCallbacker.callAll()
            }

        return (
            outerContainer,
            Signal { callback in
                let shouldUpdateUISignal = actionDataSignal.flatMapLatest { _ in
                    hideAnimationSignal.map { _ in true }.readable(initial: false)
                }

                bag += actionDataSignal.withLatestFrom(self.state.passageNameSignal)
                    .wait(until: shouldUpdateUISignal)
                    .onValueDisposePrevious { actionData, _ in
                        let innerBag = DisposeBag()

                        let hasCallbackedSignal = ReadWriteSignal<Bool>(false)

                        func performCallback(_ link: GraphQL.EmbarkLinkFragment) {
                            if !hasCallbackedSignal.value {
                                hasCallbackedSignal.value = true
                                callback(link)
                            }
                        }

                        if let selectAction = actionData?.asEmbarkSelectAction {
                            innerBag +=
                                view.addArranged(
                                    EmbarkSelectAction(
                                        state: self.state,
                                        data: selectAction
                                    )
                                )
                                .onValue(performCallback)
                        } else if let dateAction = actionData?.asEmbarkDatePickerAction {
                            innerBag +=
                                view.addArranged(
                                    EmbarkDatePickerAction(
                                        state: self.state,
                                        data: dateAction
                                    )
                                )
                                .onValue(performCallback)
                        } else if let textAction = actionData?.asEmbarkTextAction {
                            innerBag +=
                                view.addArranged(
                                    EmbarkTextAction(
                                        state: self.state,
                                        data: textAction
                                    )
                                )
                                .onValue(performCallback)
                        } else if let numberAction = actionData?.asEmbarkNumberAction?
                            .numberActionData
                        {
                            innerBag +=
                                view.addArranged(
                                    EmbarkNumberAction(
                                        state: self.state,
                                        data: numberAction
                                    )
                                )
                                .onValue(performCallback)
                        } else if let numberActionSetData = actionData?.asEmbarkNumberActionSet?
                            .data
                        {
                            let inputSet = EmbarkActionSetInputData(
                                numberActionSet: numberActionSetData,
                                state: self.state
                            )
                            innerBag += view.addArranged(inputSet).onValue(performCallback)
                        } else if let addressAutocompleteAction = actionData?
                            .asEmbarkAddressAutocompleteAction
                        {
                            innerBag +=
                                view.addArranged(
                                    EmbarkAddressAutocompleteAction(
                                        state: self.state,
                                        data: addressAutocompleteAction
                                    )
                                )
                                .onValue(performCallback)
                        } else if let textActionSet = actionData?.asEmbarkTextActionSet?
                            .textActionSetData
                        {
                            let inputSet = EmbarkActionSetInputData(
                                textActionSet: textActionSet,
                                state: self.state
                            )
                            innerBag += view.addArranged(inputSet).onValue(performCallback)
                        } else if let externalInsuranceProviderAction = actionData?
                            .asEmbarkExternalInsuranceProviderAction
                        {
                            innerBag +=
                                view.addArranged(
                                    InsuranceProviderAction(
                                        state: self.state,
                                        data: .external(
                                            externalInsuranceProviderAction
                                        )
                                    )
                                )
                                .onValue(performCallback)
                        } else if let previousInsuranceProviderAction = actionData?
                            .asEmbarkPreviousInsuranceProviderAction
                        {
                            innerBag +=
                                view.addArranged(
                                    InsuranceProviderAction(
                                        state: self.state,
                                        data: .previous(
                                            previousInsuranceProviderAction
                                        )
                                    )
                                )
                                .onValue(performCallback)
                        } else if let multiAction = actionData?.asEmbarkMultiAction {
                            innerBag +=
                                view.addArranged(
                                    MultiAction(
                                        state: self.state,
                                        data: multiAction.multiActionData
                                    )
                                )
                                .onValue(performCallback)
                        } else if let recordAction = actionData?.asEmbarkAudioRecorderAction?.audioRecorderData {
                            let audioRecorder = AudioRecorder()
                            innerBag.hold(audioRecorder)

                            let recordActionView = EmbarkRecordAction(
                                data: recordAction,
                                tracking: .init(
                                    storyName: self.state.storySignal.value?.name ?? "",
                                    store: self.state.store.getAllValues()
                                ),
                                audioRecorder: audioRecorder
                            )
                            { url in
                                self.state.store.setValue(key: recordAction.storeKey, value: url.absoluteString)
                                performCallback(recordAction.next.fragments.embarkLinkFragment)
                            }

                            let audioRecorderController = HostingView(rootView: recordActionView)

                            view.addArrangedSubview(audioRecorderController)
                            innerBag += {
                                audioRecorderController.removeFromSuperview()
                            }

                            innerBag += updateViewsCallbacker.providedSignal.onValue { _ in
                                audioRecorderController.frame = .zero
                                audioRecorderController.setNeedsLayout()
                                audioRecorderController.layoutIfNeeded()
                            }
                        }

                        return innerBag
                    }

                return bag
            }
        )
    }
}

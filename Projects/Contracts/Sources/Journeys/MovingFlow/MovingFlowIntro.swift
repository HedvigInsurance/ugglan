import Apollo
import Flow
import Form
import Foundation
import Presentation
import SwiftUI
import UIKit
import hAnalytics
import hCore
import hCoreUI
import hGraphQL

public struct MovingFlowIntro {
    @Inject var giraffe: hGiraffe
    @ReadWriteState var section = MovingFlowIntroState.none
    public init() {}
}

enum MovingFlowIntroState {
    case manual
    case existing(DetailAgreementsTable?)
    case normal(String)
    case none

    @ViewBuilder func makeButton(onTap: @escaping () -> Void) -> some View {
        switch self {
        case .existing, .manual:
            hButton.LargeButton(type: .primary) {
                onTap()
            } content: {
                hText(L10n.MovingIntro.manualHandlingButtonText)
            }
        case .normal:
            hButton.LargeButton(type: .primary) {
                onTap()
            } content: {
                hText(L10n.MovingIntro.openFlowButtonText)
            }
        case .none:
            EmptyView()
        }
    }

    var route: MovingFlowRoute? {
        switch self {
        case .manual, .existing:
            return .chat
        case let .normal(storyName):
            return .embark(name: storyName)
        case .none:
            return nil
        }
    }
}

public enum MovingFlowRoute {
    case chat
    case embark(name: String)
}

extension MovingFlowIntro: Presentable {
    public func materialize() -> (UIViewController, FiniteSignal<MovingFlowRoute>) {
        let bag = DisposeBag()
        let viewController = UIViewController()

        let scrollView = FormScrollView()

        let form = FormView()
        bag += viewController.install(form, scrollView: scrollView)

        let store: ContractStore = get()

        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.setContentHuggingPriority(.defaultLow, for: .vertical)

        let infoContainerView = UIStackView()
        infoContainerView.axis = .vertical
        infoContainerView.addArrangedSubview(imageView)
        infoContainerView.spacing = 16

        infoContainerView.layoutMargins = UIEdgeInsets(horizontalInset: 14, verticalInset: 0)
        infoContainerView.isLayoutMarginsRelativeArrangement = true

        let titleLabel = MultilineLabel(value: "", style: .brand(.title2(color: .primary)).aligned(to: .center))
        let descriptionLabel = MultilineLabel(
            value: "",
            style: .brand(.body(color: .secondary)).aligned(to: .center)
        )

        form.appendSpacing(.top)

        bag += infoContainerView.addArranged(titleLabel)
        bag += infoContainerView.addArranged(descriptionLabel)
        form.append(infoContainerView)

        bag += scrollView.didLayoutSignal.readable().withLatestFrom($section)
            .onValue { _, state in
                switch state {
                case .normal, .manual:
                    infoContainerView.snp.remakeConstraints { make in
                        make.top.equalTo((viewController.view.frame.height / 2) - (infoContainerView.frame.height))
                    }
                default:
                    break
                }
            }

        bag += $section.onValueDisposePrevious { state in
            let innerBag = DisposeBag()

            switch state {
            case .manual:
                titleLabel.$value.value = L10n.MovingIntro.manualHandlingButtonText
                descriptionLabel.$value.value = L10n.MovingIntro.manualHandlingDescription
                imageView.image = hCoreUIAssets.helicopter.image
            case let .existing(table):
                titleLabel.$value.value = L10n.MovingIntro.existingMoveTitle
                descriptionLabel.$value.value = L10n.MovingIntro.existingMoveDescription
                imageView.image = nil

                if let table = table {
                    let hostView = makeHost {
                        table.view
                    }

                    innerBag += {
                        hostView.removeFromSuperview()
                    }

                    form.append(hostView)
                }
            case .normal:
                titleLabel.$value.value = L10n.MovingIntro.title
                descriptionLabel.$value.value = L10n.MovingIntro.description
                imageView.image = hCoreUIAssets.notifications.image
            case .none:
                break
            }

            return innerBag
        }

//        bag += store.stateSignal.atOnce()
//            .onValue { state in
//                if let upcomingAgreementTable = state.activeContracts.compactMap({ $0 })
//                    .first(where: {
//                        !($0.upcomingChangedAgreement?.displayItems.isEmpty ?? false)
//                    })?
//                    .upcomingChangedAgreement
//                {
//                    $section.value = .existing(upcomingAgreementTable)
//                } else {
//                    if let bundle = state.activeContracts
//                        .first(where: { bundle in
//                            bundle != nil
//                        })
//                    {
//                        $section.value = .normal(
//                            bundle.movingFlowEmbarkId ?? ""
//                        )
//                    } else {
//                        $section.value = .manual
//                    }
//                }
//            }

        return (
            viewController,
            FiniteSignal { callbacker in
                bag += $section.atOnce()
                    .onValueDisposePrevious { state in
                        let innerBag = DisposeBag()

                        let button = state.makeButton(onTap: {
                            callbacker(.value(state.route ?? .chat))
                        })

                        let buttonContainer = UIStackView()
                        buttonContainer.isLayoutMarginsRelativeArrangement = true
                        scrollView.addSubview(buttonContainer)

                        buttonContainer.snp.makeConstraints { make in
                            make.bottom.equalTo(
                                scrollView.frameLayoutGuide.snp.bottom
                            )
                            make.trailing.leading.equalToSuperview()
                        }

                        innerBag += buttonContainer.didLayoutSignal.onValue { _ in
                            buttonContainer.layoutMargins = UIEdgeInsets(
                                top: 0,
                                left: 15,
                                bottom: scrollView.safeAreaInsets.bottom == 0
                                    ? 15 : scrollView.safeAreaInsets.bottom,
                                right: 15
                            )

                            let size = buttonContainer.systemLayoutSizeFitting(
                                .zero
                            )
                            scrollView.contentInset = UIEdgeInsets(
                                top: 0,
                                left: 0,
                                bottom: size.height,
                                right: 0
                            )
                            scrollView.scrollIndicatorInsets = UIEdgeInsets(
                                top: 0,
                                left: 0,
                                bottom: size.height,
                                right: 0
                            )
                        }

                        buttonContainer.addArrangedSubview(
                            makeHost({
                                button
                            })
                        )

                        innerBag += {
                            buttonContainer.removeFromSuperview()
                        }

                        return innerBag
                    }

                return bag
            }
        )
    }
}

import Apollo
import Flow
import Form
import Foundation
import Presentation
import UIKit
import hAnalytics
import hCore
import hCoreUI
import hGraphQL

public struct MovingFlowIntro {
    @Inject var client: ApolloClient
    @ReadWriteState var section = MovingFlowIntroState.none
    public init() {}
}

enum MovingFlowIntroState {
    case manual
    case existing(DetailAgreementsTable?)
    case normal(String)
    case none

    var button: Button? {
        switch self {
        case .existing, .manual:
            return Button(
                title: L10n.MovingIntro.manualHandlingButtonText,
                type: .standardIcon(
                    backgroundColor: .brand(.secondaryButtonBackgroundColor),
                    textColor: .brand(.secondaryButtonTextColor),
                    icon: .left(image: hCoreUIAssets.chat.image, width: 22)
                )
            )
        case .normal:
            return Button(
                title: L10n.MovingIntro.openFlowButtonText,
                type: .standard(
                    backgroundColor: .brand(.secondaryButtonBackgroundColor),
                    textColor: .brand(.secondaryButtonTextColor)
                )
            )
        default:
            return nil
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
                    innerBag += form.append(table)
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

        bag += store.stateSignal.atOnce()
            .onValue { state in
                if let upcomingAgreementTable = state.contractBundles.flatMap({ $0.contracts })
                    .first(where: {
                        !$0.upcomingAgreementsTable.sections.isEmpty
                    })?
                    .upcomingAgreementsTable
                {
                    $section.value = .existing(upcomingAgreementTable)
                } else {
                    if let bundle = state.contractBundles.first(where: { bundle in
                        bundle.movingFlowEmbarkId != nil
                    }) {
                        $section.value = .normal(
                            bundle.movingFlowEmbarkId ?? ""
                        )
                    } else {
                        $section.value = .manual
                    }
                }
            }

        bag += viewController.trackDidMoveToWindow(hAnalyticsEvent.screenViewMovingFlowIntro())

        return (
            viewController,
            FiniteSignal { callbacker in
                bag += $section.atOnce()
                    .onValueDisposePrevious { state in
                        let innerBag = DisposeBag()

                        if let button = state.button {
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

                            innerBag += buttonContainer.addArranged(button)

                            innerBag += {
                                buttonContainer.removeFromSuperview()
                            }

                            innerBag += button.onTapSignal.onValue {
                                callbacker(.value(state.route ?? .chat))
                            }
                        }

                        return innerBag
                    }

                return bag
            }
        )
    }
}

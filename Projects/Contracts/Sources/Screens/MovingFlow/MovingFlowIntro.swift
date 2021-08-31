import Apollo
import Flow
import Form
import Foundation
import Presentation
import UIKit
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

        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.setContentHuggingPriority(.defaultLow, for: .vertical)

        form.append(imageView)

        let titleLabel = MultilineLabel(value: "", style: .brand(.title2(color: .primary)).aligned(to: .center))
        let descriptionLabel = MultilineLabel(
            value: "",
            style: .brand(.body(color: .secondary)).aligned(to: .center)
        )

        form.appendSpacing(.top)

        bag += form.append(titleLabel.insetted(UIEdgeInsets(horizontalInset: 14, verticalInset: 0)))
        form.appendSpacing(.inbetween)
        bag += form.append(descriptionLabel.insetted(UIEdgeInsets(horizontalInset: 14, verticalInset: 0)))

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

            case .normal:
                titleLabel.$value.value = L10n.MovingIntro.title
                descriptionLabel.$value.value = L10n.MovingIntro.description
                imageView.image = hCoreUIAssets.notifications.image
            case .none:
                break
            }

            return innerBag
        }

        let activeContractBundles: Future<[GraphQL.ActiveContractBundlesQuery.Data.ActiveContractBundle]> =
            client.fetch(
                query: GraphQL.ActiveContractBundlesQuery(locale: Localization.Locale.currentLocale.asGraphQLLocale()),
                cachePolicy: .fetchIgnoringCacheData
            )
            .map { data in
                data.activeContractBundles
            }

        bag +=
            client.fetch(
                query: GraphQL.UpcomingAgreementQuery(
                    locale: Localization.Locale.currentLocale.asGraphQLLocale()
                ),
                cachePolicy: .fetchIgnoringCacheData
            )
            .onValue { data in
                if let contract = data.contracts.first(where: {
                    $0.status.asActiveStatus?.upcomingAgreementChange != nil
                }) {
                    $section.value = .existing(nil)
                } else {
                    bag += activeContractBundles.onValue { bundles in
                        if let bundle = bundles.first(where: {
                            $0.angelStories.addressChange != nil
                        }) {
                            $section.value = .normal(
                                bundle.angelStories.addressChange?.displayValue ?? ""
                            )
                        } else {
                            $section.value = .manual
                        }
                    }
                }
            }

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

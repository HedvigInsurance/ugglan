import Apollo
import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI
import hGraphQL

public struct Home {
    @Inject var client: ApolloClient

    public init() {}
}

public enum HomeResult {
    case startMovingFlow
    case openClaims
    case openFreeTextChat
    case openConnectPayments
}

extension Future {
    func wait(until signal: ReadSignal<Bool>) -> Future<Value> {
        Future<Value> { completion in
            let bag = DisposeBag()

            self.onValue { value in
                bag += signal.atOnce().filter(predicate: { $0 })
                    .onValue { _ in
                        completion(.success(value))
                    }
            }
            .onError { error in
                completion(.failure(error))
            }

            return bag
        }
    }
}

extension Home: Presentable {
    public func materialize() -> (UIViewController, Signal<HomeResult>) {
        let store: HomeStore = self.get()

        let viewController = LifeCycleProxyViewController()
        viewController.title = L10n.HomeTab.title
        viewController.installChatButton(allowsChatHint: true)

        if #available(iOS 13.0, *) {
            let scrollEdgeAppearance = UINavigationBarAppearance()
            DefaultStyling.applyCommonNavigationBarStyling(scrollEdgeAppearance)
            scrollEdgeAppearance.configureWithTransparentBackground()
            scrollEdgeAppearance.largeTitleTextAttributes = scrollEdgeAppearance.largeTitleTextAttributes
                .merging(
                    [
                        NSAttributedString.Key.foregroundColor: UIColor.clear
                    ],
                    uniquingKeysWith: takeRight
                )

            viewController.navigationItem.scrollEdgeAppearance = scrollEdgeAppearance
        }

        let bag = DisposeBag()

        store.send(.setMemberContractState(state: .init(state: .loading, name: nil)))

        bag += viewController.viewDidAppearSignal.onValue {
            fetch()
        }

        func fetch() {
            store.send(.fetchMemberState)
            store.send(.fetchClaims)
        }

        let form = FormView()
        bag += viewController.install(form) { scrollView in
            let refreshControl = UIRefreshControl()
            scrollView.refreshControl = refreshControl

            bag += refreshControl.store(
                store,
                send: {
                    .fetchMemberState
                },
                endOn: { action in
                    switch action {
                    case .setMemberContractState:
                        return true
                    default:
                        return false
                    }
                }
            )

            let future = store.stateSignal.atOnce()
                .filter(predicate: { $0.memberStateData.state != .loading }).future

            bag += scrollView.performEntryAnimation(
                contentView: form,
                onLoad: future
            ) { error in
                print(error)
            }
        }

        bag += form.append(ImportantMessagesSection())

        let titleSection = form.appendSection()
        titleSection.dynamicStyle = .brandGrouped(
            insets: .init(top: 14, left: 14, bottom: 14, right: 14),
            separatorType: .none
        )

        func buildSections(state: HomeState) -> Disposable {
            let innerBag = DisposeBag()

            switch state.memberStateData.state {
            case .active:

                if let name = state.memberStateData.name {
                    let label = MultilineLabel(
                        value: L10n.HomeTab.welcomeTitle(name),
                        style: .brand(.largeTitle(color: .primary))
                    )
                    innerBag += titleSection.append(label)
                }

                innerBag += form.append(ActiveSection())

                if Localization.Locale.currentLocale.market == .se {
                    let section = HomeVerticalSection(
                        section: .init(
                            title: L10n.HomeTab.editingSectionTitle,
                            style: .vertical,
                            children: [
                                .init(
                                    title: L10n.HomeTab.editingSectionChangeAddressLabel,
                                    icon: hCoreUIAssets.apartment.image,
                                    handler: {
                                        store.send(.openMovingFlow)
                                    }
                                )
                            ]
                        )
                    )

                    innerBag += form.append(section)
                }

                innerBag += form.appendSpacingAndDumpOnDispose(.custom(30))

            case .future:
                innerBag += titleSection.append(FutureSection())
            case .terminated:
                innerBag += titleSection.append(TerminatedSection())
            case .loading:
                break
            }

            return innerBag
        }

        bag += NotificationCenter.default.signal(forName: UIApplication.didBecomeActiveNotification)
            .mapLatestToFuture { _ in
                self.client.fetch(query: GraphQL.HomeQuery(), cachePolicy: .fetchIgnoringCacheData)
            }
            .nil()

        return (
            viewController,
            Signal { callback in
                bag += store.stateSignal
                    .atOnce()
                    .distinct()
                    .onValueDisposePrevious { state in
                        buildSections(state: state)
                    }

                bag += store.actionSignal.onValue { action in
                    switch action {
                    case .openFreeTextChat:
                        callback(.openFreeTextChat)
                    case .openMovingFlow:
                        callback(.startMovingFlow)
                    case .openClaims:
                        callback(.openClaims)
                    case .connectPayments:
                        callback(.openConnectPayments)
                    default:
                        break
                    }
                }

                return bag
            }
        )
    }
}

extension Home: Tabable {
    public func tabBarItem() -> UITabBarItem {
        UITabBarItem(
            title: L10n.HomeTab.title,
            image: Asset.tab.image,
            selectedImage: Asset.tabSelected.image
        )
    }
}

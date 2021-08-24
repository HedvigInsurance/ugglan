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

        store.send(.setMemberContractState(state: .loading))
        store.send(.fetchMemberState)

        let viewController = UIViewController()
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

        let form = FormView()
        bag += viewController.install(form) { scrollView in
            let refreshControl = UIRefreshControl()
            scrollView.refreshControl = refreshControl

            bag += refreshControl.store(
                store,
                send: {
                    .fetchMemberState
                },
                endOn: .setMemberContractState(state: .active),
                .setMemberContractState(state: .future),
                .setMemberContractState(state: .terminated)
            )

            let future = store.stateSignal.atOnce()
                .filter(predicate: { $0.memberContractState != .loading }).future

            bag += scrollView.performEntryAnimation(
                contentView: form,
                onLoad: future
            ) { error in
                print(error)
            }
        }

        bag += form.append(ImportantMessagesSection())

        let rowInsets = UIEdgeInsets(
            top: 0,
            left: 25,
            bottom: 0,
            right: 25
        )

        let titleSection = form.appendSection()
        let titleRow = RowView()
        titleRow.isLayoutMarginsRelativeArrangement = true
        titleRow.layoutMargins = rowInsets
        titleSection.append(titleRow)

        func buildSections(state: MemberContractState) -> Disposable {
            let innerBag = DisposeBag()

            switch state {
            case .active:
                innerBag += titleRow.append(ActiveSection())

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

                form.appendSpacing(.custom(30))
            case .future:
                innerBag += titleRow.append(FutureSection())
            case .terminated:
                innerBag += titleRow.append(TerminatedSection())
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
                bag += store.stateSignal.atOnce().map { $0.memberContractState }
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

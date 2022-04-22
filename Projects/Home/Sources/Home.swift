import Apollo
import Claims
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

// End to remove

public struct HomeSwiftUI {
    @PresentableStore var store: HomeStore
    @SwiftUI.Environment(\.cardView) var statusCard: AnyView

    var claimsContent: Claims
    var commonClaims: CommonClaimsView
    var claimSubmitHandler: () -> Void

    public init() {
        let claims = Claims()
        self.claimsContent = claims
        self.commonClaims = CommonClaimsView()
        self.claimSubmitHandler = claims.claimSubmission
    }
}

struct WithCard<Card: View>: ViewModifier {
    var card: () -> Card

    func body(content: Content) -> some View {
        VStack {
            content
            card()
        }
    }
}

extension View {
    func addStatusCard<Card: View>(_ card: @escaping () -> Card) -> some View {
        modifier(WithCard(card: card))
    }
}

extension HomeSwiftUI: View {
    func fetch() {
        store.send(.fetchMemberState)
    }

    public var body: some View {
        hForm {
            hSection {
                PresentableStoreLens(
                    HomeStore.self,
                    getter: { state in
                        state.memberStateData
                    }
                ) { memberStateData in
                    switch memberStateData.state {
                    case .active:
                        if let name = memberStateData.name {
                            hText(L10n.HomeTab.welcomeTitle(name), style: .largeTitle)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .addStatusCard {
                                    statusCard
                                }
                        }
                        ActiveSessionView(claimsContent: claimsContent, commonClaims: commonClaims)
                    case .future:
                        Text("Future")
                    case .terminated:
                        Text("Terminated")
                    case .loading:
                        Text("Loading")
                    }
                }
            }
            .sectionContainerStyle(.transparent)
        }
        .onAppear {
            fetch()
        }
    }
}

private struct CardViewKey: EnvironmentKey {
    static let defaultValue: AnyView = AnyView(Text("Hello"))
}

extension EnvironmentValues {
    var cardView: AnyView {
        get { self[CardViewKey.self] }
        set { self[CardViewKey.self] = AnyView(newValue) }
    }
}

extension View {
    public func statusCard<V: View>(_ card: @escaping () -> V) -> some View {
        environment(\.cardView, AnyView(card()))
    }
}

extension HomeSwiftUI {
    public static func journey<ResultJourney: JourneyPresentation, V: View>(
        statusCardView: @escaping () -> V,
        @JourneyBuilder resultJourney: @escaping (_ result: HomeResult) -> ResultJourney
    ) -> some JourneyPresentation {
        HostingJourney(
            HomeStore.self,
            rootView: HomeSwiftUI()
                .statusCard {
                    // Is it really a good idea to use EnvironmentValues here? Maybe just pass it down as a parameter to HomeSwiftUI?
                    statusCardView()
                },
            options: [
                .defaults,
                .prefersLargeTitles(true),
                .largeTitleDisplayMode(.always),
            ]
        ) { action in
            if case .openFreeTextChat = action {
                resultJourney(.openFreeTextChat)
            } else if case .openMovingFlow = action {
                resultJourney(.startMovingFlow)
            } else if case .connectPayments = action {
                resultJourney(.openConnectPayments)
            }
        }
        .configureTitle(L10n.HomeTab.title)
        .addConfiguration({ presenter in
            // - TODO - refactor
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

            let tabBarItem = UITabBarItem(
                title: L10n.HomeTab.title,
                image: Asset.tab.image,
                selectedImage: Asset.tabSelected.image
            )
            presenter.viewController.tabBarItem = tabBarItem

            guard let navigationController = presenter.viewController as? UINavigationController else {
                presenter.viewController.navigationItem.scrollEdgeAppearance = scrollEdgeAppearance
                return
            }
            navigationController.viewControllers.first?.navigationItem.scrollEdgeAppearance = scrollEdgeAppearance
            presenter.viewController.navigationItem.scrollEdgeAppearance = scrollEdgeAppearance
        })
    }
}

public struct Home<ClaimsContent: View, CommonClaims: View> {
    @Inject var client: ApolloClient
    var claimsContent: ClaimsContent
    var commonClaims: CommonClaims
    var claimSubmitHandler: () -> Void

    public init(
        claimsContent: ClaimsContent,
        commonClaims: CommonClaims,
        _ claimSubmitHandler: @escaping () -> Void
    ) {
        self.claimsContent = claimsContent
        self.commonClaims = commonClaims
        self.claimSubmitHandler = claimSubmitHandler
    }
}

public enum HomeResult {
    case startMovingFlow
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

        store.send(.setMemberContractState(state: .init(state: .loading, name: nil)))

        let onAppearProxy = SwiftUI.Color.clear.onAppear {
            fetch()
        }

        let hostingProxy = HostingView(rootView: onAppearProxy)

        func fetch() {
            store.send(.fetchMemberState)
        }

        let form = FormView()
        bag += viewController.install(form) { scrollView in
            let refreshControl = UIRefreshControl()
            scrollView.refreshControl = refreshControl

            scrollView.addSubview(hostingProxy)

            bag += refreshControl.store(
                store,
                send: {
                    [
                        .fetchMemberState
                    ]
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
                    let label = makeHost {
                        hText(L10n.HomeTab.welcomeTitle(name), style: .largeTitle)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    innerBag += titleSection.appendRemovable(label)
                }

                innerBag += form.append(
                    ActiveSection(
                        claimsContent: self.claimsContent,
                        commonClaims: self.commonClaims
                    )
                )

                if hAnalyticsExperiment.movingFlow {
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
                innerBag += titleSection.append(TerminatedSection(claimSubmitHandler))
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

        viewController.trackOnAppear(hAnalyticsEvent.screenView(screen: .home))

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

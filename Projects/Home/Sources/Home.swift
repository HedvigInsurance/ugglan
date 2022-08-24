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

public struct HomeSwiftUI<Content: View>: View {
    @PresentableStore var store: HomeStore

    var statusCard: Content

    var claimsContent: Claims
    var commonClaims: CommonClaimsView
    var claimSubmitHandler: () -> Void

    public init(
        statusCard: () -> Content
    ) {
        self.statusCard = statusCard()
        let claims = Claims()
        self.claimsContent = claims
        self.commonClaims = CommonClaimsView()
        self.claimSubmitHandler = claims.claimSubmission
    }
}

extension HomeSwiftUI {
    func fetch() {
        store.send(.fetchMemberState)
        store.send(.fetchFutureStatus)
    }

    public var body: some View {
        hForm(gradientType: .home) {
            PresentableStoreLens(
                HomeStore.self,
                getter: { state in
                    state.memberStateData
                }
            ) { memberStateData in
                switch memberStateData.state {
                case .active:
                    ActiveSectionView(claimsContent: claimsContent, commonClaims: commonClaims, statusCard: statusCard)
                case .future:
                    FutureSectionView(memberName: memberStateData.name ?? "")
                        .slideUpFadeAppearAnimation()
                case .terminated:
                    TerminatedSectionView(memberName: memberStateData.name ?? "", claimsContent: claimsContent)
                        .slideUpFadeAppearAnimation()
                case .loading:
                    EmptyView()
                }
            }
        }
        .withChatButton(tooltip: true) {
            store.send(.openFreeTextChat)
        }
        .onAppear {
            fetch()
        }
        .trackOnAppear(hAnalyticsEvent.screenView(screen: .home))
    }
}

extension HomeSwiftUI {
    public static func journey<ResultJourney: JourneyPresentation>(
        @JourneyBuilder resultJourney: @escaping (_ result: HomeResult) -> ResultJourney,
        statusCard: @escaping () -> Content
    ) -> some JourneyPresentation {
        HostingJourney(
            HomeStore.self,
            rootView: HomeSwiftUI(statusCard: statusCard),
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
            } else if case let .openDocument(contractURL) = action {
                Journey(
                    Document(url: contractURL, title: L10n.insuranceCertificateTitle),
                    style: .detented(.large),
                    options: .defaults
                )
            }
        }
        .configureTitle(L10n.HomeTab.title)
        .configureTabBarItem(title: L10n.HomeTab.title, image: Asset.tab.image, selectedImage: Asset.tabSelected.image)
        .configureHomeScroll()
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

        let bag = DisposeBag()

        store.send(.setMemberContractState(state: .init(state: .loading, name: nil), contracts: []))

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
                        hText(L10n.HomeTab.welcomeTitle(name), style: .prominentTitle)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, alignment: .center)
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
                innerBag += titleSection.append(TerminatedSection(claimsContent: claimsContent))
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

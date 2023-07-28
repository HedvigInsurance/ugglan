import Apollo
import Flow
import Form
import Foundation
import Presentation
import SafariServices
import SwiftUI
import hAnalytics
import hCore
import hCoreUI
import hGraphQL

public struct HomeView<Content: View, Claims: View>: View {
    @PresentableStore var store: HomeStore

    var statusCard: Content

    var claimsContent: Claims
    var memberId: String

    public init(
        claimsContent: Claims,
        statusCard: () -> Content,
        memberId: @escaping () -> String
    ) {
        self.statusCard = statusCard()
        self.claimsContent = claimsContent

        self.memberId = memberId()
    }
}

extension HomeView {
    func fetch() {
        store.send(.fetchMemberState)
        store.send(.fetchFutureStatus)
        store.send(.fetchImportantMessages)
    }

    public var body: some View {
        hForm {
            ImportantMessagesView()
            PresentableStoreLens(
                HomeStore.self,
                getter: { state in
                    state.memberStateData
                }
            ) { memberStateData in
                switch memberStateData.state {
                case .active:
                    ActiveSectionView(
                        claimsContent: claimsContent,
                        memberId: memberId
                    )
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
        .hFormAttachToBottom {
            hSection {
                VStack(spacing: 8) {
                    statusCard
                    hButton.LargeButtonPrimary {
                        hAnalyticsEvent.beginClaim(screen: .home).send()
                        store.send(.startClaim)
                    } content: {
                        hText(L10n.HomeTab.claimButtonText)
                    }

                    if hAnalyticsExperiment.homeCommonClaim {
                        hButton.LargeButtonGhost {
                            store.send(.openOtherServices)
                        } content: {
                            hText(L10n.HomeTab.otherServices)
                        }
                    }
                }
            }
            .sectionContainerStyle(.transparent)
        }
    }
}

extension HomeView {
    public static func journey<ResultJourney: JourneyPresentation>(
        claimsContent: Claims,
        memberId: @escaping () -> String,
        @JourneyBuilder resultJourney: @escaping (_ result: HomeResult) -> ResultJourney,
        statusCard: @escaping () -> Content
    ) -> some JourneyPresentation {
        HostingJourney(
            HomeStore.self,
            rootView: HomeView(
                claimsContent: claimsContent,
                statusCard: statusCard,
                memberId: memberId
            ),
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
            } else if case .openOtherServices = action {
                resultJourney(.openOtherServices)
            } else if case .startClaim = action {
                resultJourney(.startNewClaim)
            }
        }
        .configureTitle(L10n.HomeTab.title)
        .configureTabBarItem(
            title: L10n.HomeTab.title,
            image: hCoreUIAssets.homeTab.image,
            selectedImage: hCoreUIAssets.homeTabActive.image
        )
        .configureHomeScroll()
    }
}

public enum HomeResult {
    case startMovingFlow
    case openFreeTextChat
    case openConnectPayments
    case openOtherServices
    case startNewClaim
}

struct Active_Preview: PreviewProvider {
    static var previews: some View {
        Localization.Locale.currentLocale = .en_SE

        return HomeView(claimsContent: Text("")) {
            Text("")
        } memberId: {
            "ID"
        }
        .onAppear {
            let store: HomeStore = globalPresentableStoreContainer.get()
            let contract = GiraffeGraphQL.HomeQuery.Data.Contract(
                displayName: "DISPLAY NAME",
                switchedFromInsuranceProvider: "switchedFromInsuranceProvider",
                status: .makeActiveStatus(),
                upcomingRenewal: .init(
                    renewalDate: "2023-11-11",
                    draftCertificateUrl: "URL"
                )
            )
            store.send(
                .setMemberContractState(
                    state: .init(state: .active, name: "NAME"),
                    contracts: [.init(contract: contract)]
                )
            )
            store.send(.setFutureStatus(status: .none))
            store.send(.setImportantMessage(message: .init(message: nil, link: nil)))
        }

    }
}

struct ActiveInFuture_Previews: PreviewProvider {
    static var previews: some View {
        Localization.Locale.currentLocale = .en_SE
        return HomeView(claimsContent: Text("")) {
            Text("")
        } memberId: {
            "ID"
        }
        .onAppear {
            let store: HomeStore = globalPresentableStoreContainer.get()
            let contract = GiraffeGraphQL.HomeQuery.Data.Contract(
                displayName: "DISPLAY NAME",
                switchedFromInsuranceProvider: "switchedFromInsuranceProvider",
                status: .makeActiveInFutureStatus(futureInception: "2023-11-22"),
                upcomingRenewal: .init(
                    renewalDate: "2023-11-11",
                    draftCertificateUrl: "URL"
                )
            )
            store.send(
                .setMemberContractState(
                    state: .init(state: .future, name: "NAME"),
                    contracts: [.init(contract: contract)]
                )
            )
            store.send(.setFutureStatus(status: .pendingSwitchable))
            store.send(.setImportantMessage(message: .init(message: "MESSAGE", link: "https://www.hedvig.com")))
        }

    }
}

struct TerminatedToday_Previews: PreviewProvider {
    static var previews: some View {
        Localization.Locale.currentLocale = .en_SE
        return HomeView(claimsContent: Text("")) {
            Text("")
        } memberId: {
            "ID"
        }
        .onAppear {
            let store: HomeStore = globalPresentableStoreContainer.get()
            let contract = GiraffeGraphQL.HomeQuery.Data.Contract(
                displayName: "DISPLAY NAME",
                switchedFromInsuranceProvider: "switchedFromInsuranceProvider",
                status: .makeTerminatedTodayStatus(),
                upcomingRenewal: .init(
                    renewalDate: "2023-11-11",
                    draftCertificateUrl: "URL"
                )
            )
            store.send(
                .setMemberContractState(
                    state: .init(state: .terminated, name: "NAME"),
                    contracts: [.init(contract: contract)]
                )
            )
            store.send(.setFutureStatus(status: .pendingSwitchable))
            store.send(.setImportantMessage(message: .init(message: "MESSAGE", link: "https://www.hedvig.com")))
        }

    }
}

struct Terminated_Previews: PreviewProvider {
    static var previews: some View {
        Localization.Locale.currentLocale = .en_SE
        return HomeView(claimsContent: Text("")) {
            Text("")
        } memberId: {
            "ID"
        }
        .onAppear {
            let store: HomeStore = globalPresentableStoreContainer.get()
            let contract = GiraffeGraphQL.HomeQuery.Data.Contract(
                displayName: "DISPLAY NAME",
                switchedFromInsuranceProvider: "switchedFromInsuranceProvider",
                status: .makeTerminatedStatus(),
                upcomingRenewal: .init(
                    renewalDate: "2023-11-11",
                    draftCertificateUrl: "URL"
                )
            )
            store.send(
                .setMemberContractState(
                    state: .init(state: .terminated, name: "NAME"),
                    contracts: [.init(contract: contract)]
                )
            )
            store.send(.setFutureStatus(status: .pendingSwitchable))
            store.send(.setImportantMessage(message: .init(message: "MESSAGE", link: "https://www.hedvig.com")))
        }

    }
}

struct Deleted_Previews: PreviewProvider {
    static var previews: some View {
        Localization.Locale.currentLocale = .en_SE
        return HomeView(claimsContent: Text("")) {
            Text("")
        } memberId: {
            "ID"
        }
        .onAppear {
            let store: HomeStore = globalPresentableStoreContainer.get()
            let contract = GiraffeGraphQL.HomeQuery.Data.Contract(
                displayName: "DISPLAY NAME",
                switchedFromInsuranceProvider: "switchedFromInsuranceProvider",
                status: .makeDeletedStatus(),
                upcomingRenewal: .init(
                    renewalDate: "2023-11-11",
                    draftCertificateUrl: "URL"
                )
            )
            store.send(
                .setMemberContractState(
                    state: .init(state: .terminated, name: "NAME"),
                    contracts: [.init(contract: contract)]
                )
            )
            store.send(.setFutureStatus(status: .pendingSwitchable))
            store.send(.setImportantMessage(message: .init(message: nil, link: nil)))
        }

    }
}

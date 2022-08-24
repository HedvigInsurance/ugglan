import Apollo
import Claims
import Flow
import Form
import Foundation
import Presentation
import SafariServices
import SwiftUI
import UIKit
import hAnalytics
import hCore
import hCoreUI
import hGraphQL

public struct HomeView<Content: View>: View {
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

extension HomeView {
    func fetch() {
        store.send(.fetchMemberState)
        store.send(.fetchFutureStatus)
        store.send(.fetchImportantMessages)
    }

    public var body: some View {
        hForm(gradientType: .home) {
            ImportantMessagesView()

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

extension HomeView {
    public static func journey<ResultJourney: JourneyPresentation>(
        @JourneyBuilder resultJourney: @escaping (_ result: HomeResult) -> ResultJourney,
        statusCard: @escaping () -> Content
    ) -> some JourneyPresentation {
        HostingJourney(
            HomeStore.self,
            rootView: HomeView(statusCard: statusCard),
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

public enum HomeResult {
    case startMovingFlow
    case openFreeTextChat
    case openConnectPayments
}

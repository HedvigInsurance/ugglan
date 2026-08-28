import AppStateContainer
import Claims
import Contracts
import CrossSell
import Payment
import SwiftUI
import hCore
import hCoreUI

struct ActiveHomeView: View {
    @AppObservedObject private var homeStore: HomeStore
    @AppObservedObject private var claimsStore: ClaimsStore
    @AppObservedObject private var crossSellStore: CrossSellStore
    @StateObject private var bottomVm = HomeBottomScrollViewModel()
    @State private var greetingHeight: CGFloat = 0
    @State private var headerHeight: CGFloat = 0
    @State private var scrollOffset: CGFloat = 0
    @State private var navBarHeight: CGFloat = 0
    @State private var topSafeAreaInset: CGFloat = 0

    private let scrollSpace = "homeScroll"

    /// Keeps the surface's white reaching a touch past the last item, like the old sheet did.
    private let surfaceBottomGap: CGFloat = .padding8

    /// On iPad the scroll content floats as a centered column instead of hugging the screen width.
    private let maxContentWidth: CGFloat = 600

    /// White below the sheet's end so rubber-banding never exposes the hero through the bottom.
    private let bottomOverscrollExtension: CGFloat = 500

    /// How far the content dissolves before it slips under the pinned header.
    private let contentFadeHeight: CGFloat = 4

    var body: some View {
        GeometryReader { proxy in
            let viewportHeight = proxy.size.height + proxy.safeAreaInsets.bottom
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                    Section {
                        GreetingView(firstName: homeStore.memberInfo?.firstName)
                            .onGeometryChange(for: CGFloat.self, of: \.size.height) { height in
                                // The greeting is lazy: once scrolled off it's recycled and
                                // reports 0, which would blow up the clip inset and the sheet's
                                // minimum height. Latch the last real measurement.
                                if height > 0 { greetingHeight = height }
                            }
                            .offset(x: 0, y: scrollOffset > 0 ? -(scrollOffset / 2) : -(scrollOffset / 3))
                    }
                    Section {
                        sheetContent
                            .padding(.bottom, proxy.safeAreaInsets.bottom + surfaceBottomGap)
                            // The sheet must always reach the screen bottom at rest.
                            .frame(minHeight: viewportHeight - greetingHeight - headerHeight, alignment: .top)
                            // Two masks, with the surface sandwiched between them. This one runs
                            // before the background, so it fades the content alone: text and cards
                            // dissolve into the sheet rather than vanishing mid-glyph.
                            .mask(alignment: .top) {
                                topFadeMask(
                                    topInset: max(0, -scrollOffset - greetingHeight),
                                    fadeHeight: contentFadeHeight
                                )
                            }
                            .background(Rectangle().fill(hFillColor.Translucent.primary))
                            // ...and this one runs after, hard-cutting content *and* surface at the
                            // header's bottom edge. The sheet keeps a crisp top edge instead of
                            // showing through the transparent chips row. Once scrolled past the
                            // greeting, `-scrollOffset - greetingHeight` is exactly how far the
                            // content has gone under the header.
                            // Keep both masks in sync — the fade only reads correctly when the
                            // hard cut lands on the same inset.
                            .mask(alignment: .top) {
                                topFadeMask(topInset: max(0, -scrollOffset - greetingHeight), fadeHeight: 0)
                            }
                    } header: {
                        HomeSheetContainer()
                            .onGeometryChange(for: CGFloat.self, of: \.size.height) { headerHeight = $0 }
                    }
                }
                .frame(maxWidth: maxContentWidth)
                .frame(maxWidth: .infinity)
                .onGeometryChange(for: CGFloat.self, of: { $0.frame(in: .named(scrollSpace)).minY }) {
                    scrollOffset = $0
                }
            }
            .coordinateSpace(name: scrollSpace)
            .ignoresSafeArea(edges: .bottom)
            .onGeometryChange(for: CGFloat.self, of: \.safeAreaInsets.top) { topSafeAreaInset = $0 }
            .overlay(alignment: .topTrailing) {
                HomeNavigationBar()
                    .padding(.vertical, .padding4)
                    .onGeometryChange(for: CGFloat.self, of: \.size.height) { navBarHeight = $0 }
                    .opacity(showNavigation ? 1 : 0)
                    .offset(y: showNavigation ? 0 : -30)
                    .animation(.easeInOut(duration: 0.2), value: scrollOffset)
            }
        }
        .background { heroBackground }
    }

    private var showNavigation: Bool {
        guard greetingHeight > 0 else { return true }
        return scrollOffset + greetingHeight - navBarHeight > 0
    }

    private var heroBackground: some View {
        hCoreUIAssets.submitClaimBg.view
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
            .accessibilityHidden(true)
    }

    private var sheetContent: some View {
        VStack(spacing: .padding40) {
            ClaimsCard(allActiveClaims: claimsStore.allActiveClaims)
            infoMessagesCarouselSection
            TodoList(todos: bottomVm.todos)
            HomeOngoingQuotesSection(quotes: homeStore.ongoingQuotes)
            HomeQuickActionsSection(quickActions: homeStore.homeQuickActions)
            HomeCrossSellsSection(crossSells: crossSellStore.homeCrossSells)
            HomeAddonsSection(addonBanners: crossSellStore.addonBanners)
        }
        // Keeps the first card clear of the fade band while the sheet sits at rest. Once
        // scrolled, the band travels down through the content and this no longer compensates.
        .padding(.top, contentFadeHeight)
        .sectionContainerStyle(.transparent)
        .background(alignment: .bottom) {
            Rectangle()
                .fill(hFillColor.Translucent.primary)
                .frame(height: bottomOverscrollExtension)
                .offset(y: bottomOverscrollExtension)
        }
    }

    @ViewBuilder private var infoMessagesCarouselSection: some View {
        if !bottomVm.items.isEmpty {
            hSection { HomeBottomScrollView(vm: bottomVm) }
                .sectionContainerStyle(.transparent)
        }
    }

    /// Hides the top `topInset` points outright, then fades the next `fadeHeight` points from
    /// transparent to opaque.
    ///
    /// Both of `body`'s masks use this: a non-zero `fadeHeight` dissolves the content's edge, and
    /// `0` collapses the gradient to nothing for a hard cut.
    ///
    /// The negative bottom padding stretches the mask `bottomOverscrollExtension` points past the
    /// content's own bottom edge, so the white overscroll rectangle drawn below `sheetContent`
    /// survives both masks instead of being clipped away.
    @ViewBuilder private func topFadeMask(topInset: CGFloat, fadeHeight: CGFloat) -> some View {
        VStack(spacing: 0) {
            Color.clear
                .frame(height: topInset)
            LinearGradient(colors: [.clear, .black], startPoint: .top, endPoint: .bottom)
                .frame(height: fadeHeight)
            Color.black
        }
        .padding(.bottom, -bottomOverscrollExtension)
    }
}
private struct HomeNavigationBar: View {
    @AppObservedObject private var homeStore: HomeStore
    @EnvironmentObject private var navigationVm: HomeNavigationViewModel

    var body: some View {
        if #available(iOS 26.0, *) {
            GlassEffectContainer(spacing: .padding8) {
                toolbar()
            }
        } else {
            toolbar()
        }
    }

    private func toolbar() -> some View {
        HStack(spacing: .padding8) {
            ForEach(homeStore.toolbarOptionTypes, id: \.self) { type in
                barButton(for: type)
            }
        }
        .padding(.horizontal, .padding16)
    }

    @ViewBuilder
    private func barButton(for type: ToolbarOptionType) -> some View {
        let button = ToolbarButtonView(
            type: type,
            placement: .trailing,
            action: { [weak navigationVm] type in
                switch type {
                case .crossSell:
                    NotificationCenter.default.post(name: .openCrossSell, object: CrossSellInfo(type: .home))
                case .firstVet:
                    navigationVm?.quickActionsVm
                        .perform(.firstVet(partners: homeStore.quickActions.getFirstVetPartners ?? []))
                case .chat: navigationVm?.router.push(HomeRouterAction.inbox)
                case .travelCertificate, .insuranceEvidence:
                    break
                }
            },
            size: .padding40 + .padding4
        )
        if #available(iOS 26.0, *) {
            button.glassEffect(.regular.interactive(), in: Circle())
        } else {
            button
        }
    }
}

@MainActor private func setUpActiveHomeViewPreview() {
    Localization.Locale.currentLocale.send(.en_SE)
    Dependencies.shared.add(module: Module { () -> HomeClient in HomeClientDemo() })
    Dependencies.shared.add(module: Module { () -> FeatureFlags in FeatureFlags.shared })
    Dependencies.shared.add(module: Module { () -> FeatureFlagsClient in FeatureFlagsDemo() })
    Dependencies.shared.add(module: Module { () -> FetchContractsClient in FetchContractsClientDemo() })
    Dependencies.shared.add(module: Module { () -> hPaymentClient in hPaymentClientDemo() })
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    Dependencies.shared.add(module: Module { () -> hFetchClaimsClient in FetchClaimsClientDemo() })
    Dependencies.shared.add(module: Module { () -> CrossSellClient in CrossSellClientDemo() })

    let store: HomeStore = globalAppStateContainer.get()
    store.setFutureStatus(.none)
    Task {
        await store.fetchMemberState()
        store.setMemberContractState(
            .active,
            contracts: [
                .init(
                    upcomingRenewal: .init(renewalDate: "2026-08-30", draftCertificateUrl: nil),
                    displayName: "Home Insurance"
                )
            ]
        )
        let crossSellStore: CrossSellStore = globalAppStateContainer.get()
        await crossSellStore.fetchHomeCrossSells()
        await crossSellStore.fetchAddonBanners()
    }
}

#Preview {
    setUpActiveHomeViewPreview()
    return ActiveHomeView()
        .environmentObject(HomeNavigationViewModel())
}

#Preview("In tab bar") {
    setUpActiveHomeViewPreview()

    return TabView {
        ActiveHomeView()
            .environmentObject(HomeNavigationViewModel())
            .tabItem {
                hCoreUIAssets.homeTabActive.view
                hText(L10n.tabHomeTitle)
            }
        Color.clear
            .tabItem {
                hCoreUIAssets.contractTab.view
                hText(L10n.tabInsurancesTitle)
            }
        Color.clear
            .tabItem {
                hCoreUIAssets.foreverTab.view
                hText(L10n.tabReferralsTitle)
            }
        Color.clear
            .tabItem {
                hCoreUIAssets.paymentsTab.view
                hText(L10n.tabPaymentsTitle)
            }
        Color.clear
            .tabItem {
                hCoreUIAssets.profileTab.view
                hText(L10n.ProfileTab.title)
            }
    }
}

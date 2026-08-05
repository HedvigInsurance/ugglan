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
    private let scrollSpace = "homeScroll"

    /// Keeps the surface's white reaching a touch past the last item, like the old sheet did.
    private let surfaceBottomGap: CGFloat = .padding8

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
                            .background(Rectangle().fill(hFillColor.Translucent.primary))
                            // Trim the content as it rises past the pinned header's bottom edge
                            // so it disappears beneath the header instead of showing through
                            // the transparent chips row. Once scrolled past the greeting,
                            // `-scrollOffset - greetingHeight` is exactly how far the content
                            // has gone under the header.
                            .clipShape(TopClipShape(topInset: max(0, -scrollOffset - greetingHeight)))
                    } header: {
                        HomeSheetContainer()
                            .onGeometryChange(for: CGFloat.self, of: \.size.height) { headerHeight = $0 }
                    }
                }
                .onGeometryChange(for: CGFloat.self, of: { $0.frame(in: .named(scrollSpace)).minY }) {
                    scrollOffset = $0
                }
            }
            .coordinateSpace(name: scrollSpace)
            .ignoresSafeArea(edges: .bottom)
        }
        .background { heroBackground }
        // The hero runs behind the navigation bar. Once content scrolls under it UIKit swaps in
        // the standard appearance, whose background material would paint a band across the image.
        .toolbarBackground(.hidden, for: .navigationBar)
    }

    private var heroBackground: some View {
        hCoreUIAssets.submitClaimBg.view
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
            .accessibilityHidden(true)
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(hFillColor.Translucent.primary)
                    .frame(height: scrollOffset > -100 ? 0 : 300)
            }
    }

    private var sheetContent: some View {
        VStack(spacing: .padding40) {
            ClaimsCard(allActiveClaims: claimsStore.allActiveClaims)
            infoMessagesCarouselSection
            TodoList(todos: bottomVm.todos)
            HomeQuickActionsSection(quickActions: homeStore.quickActions)
            HomeCrossSellsSection(crossSells: crossSellStore.homeCrossSells)
            HomeAddonsSection(addonBanners: crossSellStore.addonBanners)
        }
        .sectionContainerStyle(.transparent)
    }

    @ViewBuilder private var infoMessagesCarouselSection: some View {
        if !bottomVm.items.isEmpty {
            hSection { HomeBottomScrollView(vm: bottomVm) }
                .sectionContainerStyle(.transparent)
        }
    }
}

/// Clips a view by trimming `topInset` points off its top edge, revealing the rest below.
/// Used to make scrolling content vanish beneath the pinned header.
private struct TopClipShape: Shape {
    var topInset: CGFloat

    func path(in rect: CGRect) -> Path {
        let inset = min(max(0, topInset), rect.height)
        return Path(
            CGRect(x: rect.minX, y: rect.minY + inset, width: rect.width, height: rect.height - inset)
        )
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

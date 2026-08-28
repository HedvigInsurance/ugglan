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

    private let scrollSpace = "homeScroll"

    /// Keeps the surface's white reaching a touch past the last item, like the old sheet did.
    private let surfaceBottomGap: CGFloat = .padding8

    /// On iPad the scroll content floats as a centered column instead of hugging the screen width.
    private let maxContentWidth: CGFloat = 600

    /// White below the sheet's end so rubber-banding never exposes the hero through the bottom.
    private let bottomOverscrollExtension: CGFloat = 500

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
                    } header: {
                        HomeNavigationBar()
                            .padding(.vertical, .padding8)
                            .onGeometryChange(for: CGFloat.self, of: \.size.height) { navBarHeight = $0 }
                    }
                    Section {
                        sheetContent
                            .padding(.bottom, proxy.safeAreaInsets.bottom + surfaceBottomGap)
                            // The sheet must always reach the screen bottom at rest.
                            .frame(
                                minHeight: viewportHeight - greetingHeight - headerHeight - navBarHeight,
                                alignment: .top
                            )
                            .background(Rectangle().fill(hFillColor.Translucent.primary))
                            // Trim the content as it rises past the pinned header's bottom edge
                            // so it disappears beneath the header instead of showing through
                            // the transparent chips row. Once scrolled past the greeting,
                            // `-scrollOffset - greetingHeight` is exactly how far the content
                            // has gone under the header.
                            .clipShape(
                                TopClipShape(
                                    topInset: max(0, -scrollOffset - greetingHeight - navBarHeight),
                                    bottomExtension: bottomOverscrollExtension
                                )
                            )
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
        }
        .background { heroBackground }
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
            Spacer()
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
            size: .padding40
        )
        if #available(iOS 26.0, *) {
            button.glassEffect(.regular.interactive(), in: Circle())
        } else {
            button
        }
    }
}

/// Clips a view by trimming `topInset` points off its top edge, revealing the rest below.
/// Used to make scrolling content vanish beneath the pinned header.
private struct TopClipShape: Shape {
    var topInset: CGFloat
    var bottomExtension: CGFloat

    func path(in rect: CGRect) -> Path {
        let inset = min(max(0, topInset), rect.height)
        return Path(
            CGRect(
                x: rect.minX,
                y: rect.minY + inset,
                width: rect.width,
                height: rect.height - inset + bottomExtension
            )
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

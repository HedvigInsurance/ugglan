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
    @State var scrollOffset: CGFloat = 0
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                Section {
                    GreetingView(firstName: homeStore.memberInfo?.firstName)
                        .background(
                            GeometryReader { proxy in
                                Color.clear.preference(
                                    key: GreetingHeightKey.self,
                                    value: proxy.size.height
                                )
                            }
                        )
                }

                Section {
                    sheetContent
                        // Trim the content as it rises past the header's bottom edge so
                        // it disappears beneath the header instead of showing through it.
                        // Once scrolled past the greeting, `-scrollOffset - greetingHeight`
                        // is exactly how far the content has gone under the pinned header.
                        .clipShape(TopClipShape(topInset: max(0, -scrollOffset - greetingHeight)))
                } header: {
                    hText("HEADER")
                }
            }
            .background(
                GeometryReader { proxy in
                    Color.clear.preference(
                        key: ScrollOffsetKey.self,
                        value: proxy.frame(in: .named("scroll")).minY
                    )
                }
            )
        }
        .coordinateSpace(name: "scroll")
        .onPreferenceChange(ScrollOffsetKey.self) { scrollOffset = $0 }
        .onPreferenceChange(GreetingHeightKey.self) { value in
            // The greeting is lazy: once scrolled off it's recycled and reports 0,
            // which would blow up the clip inset. Latch the last real measurement.
            if value > 0 { greetingHeight = value }
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
            HomeCrossSellsSection(crossSells: crossSellStore.homeCrossSells)
            HomeAddonsSection(addonBanners: crossSellStore.addonBanners)
            Rectangle().frame(width: 100, height: 1000)
        }
        .padding(.top, .padding16)
    }

    @ViewBuilder private var infoMessagesCarouselSection: some View {
        if !bottomVm.items.isEmpty {
            hSection { HomeBottomScrollView(vm: bottomVm) }
                .sectionContainerStyle(.transparent)
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
private struct ScrollOffsetKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {}
}
private struct GreetingHeightKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {}
}

/// Clips a view by trimming `topInset` points off its top edge, revealing the
/// rest below. Used to make scrolling content vanish beneath a pinned header.
private struct TopClipShape: Shape {
    var topInset: CGFloat
    func path(in rect: CGRect) -> Path {
        let inset = min(max(0, topInset), rect.height)
        return Path(
            CGRect(x: rect.minX, y: rect.minY + inset, width: rect.width, height: rect.height - inset)
        )
    }
}

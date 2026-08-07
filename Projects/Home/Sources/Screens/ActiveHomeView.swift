import AppStateContainer
import Claims
import Contracts
import Payment
import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect
import hCore
import hCoreUI

struct ActiveHomeView: View {
    @AppObservedObject private var homeStore: HomeStore
    @AppObservedObject private var claimsStore: ClaimsStore
    @StateObject private var bottomVm = HomeBottomScrollViewModel()
    @State private var handoff = NestedScrollHandoff()
    @State private var greetingHeight: CGFloat = 0

    var body: some View {
        GeometryReader { proxy in
            let viewportHeight = proxy.size.height + proxy.safeAreaInsets.bottom
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    GreetingView(firstName: homeStore.memberInfo?.firstName)
                        .onGeometryChange(for: CGFloat.self, of: \.size.height) { greetingHeight = $0 }
                    HomeSheetContainer(
                        bottomInset: proxy.safeAreaInsets.bottom,
                        minHeight: viewportHeight - greetingHeight,
                        maxHeight: viewportHeight,
                        handoff: handoff
                    ) {
                        sheetContent
                    }
                }
            }
            .ignoresSafeArea(edges: .bottom)
            .introspect(.scrollView, on: .iOS(.v13...)) { scrollView in
                // Never hand this scroll view to setContentScrollView(_:for:) — on iOS 27 that
                // severs hit-testing for everything scrolled: taps and horizontal pans die.
                handoff.connect(outer: scrollView)
                // The sheet's end must never leave the screen bottom. Letting UIKit refuse the
                // overscroll beats clamping offsets from the observer: programmatic scroll writes
                // mid-gesture cancel the horizontal pans inside the sheet on iOS 27.
                scrollView.bounces = false
            }
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
    }

    private var sheetContent: some View {
        VStack(spacing: .padding40) {
            ClaimsCard(allActiveClaims: claimsStore.allActiveClaims)
            bannerSection
            TodoList(todos: bottomVm.todos)
        }
        .padding(.top, .padding16)
    }

    @ViewBuilder private var bannerSection: some View {
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
                hCoreUIAssets.homeTab.view
                hText(L10n.tabHomeTitle)
            }
    }
}

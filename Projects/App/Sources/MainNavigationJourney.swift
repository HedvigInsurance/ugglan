import Chat
import Claims
import Contracts
import EditCoInsured
import EditCoInsuredShared
import Forever
import Home
import Payment
import Presentation
import Profile
import SwiftUI
import TravelCertificate
import hCore
import hCoreUI

class MainNavigationViewModel: ObservableObject {
    @Published var selectedTab = 0
    @Published var hasLaunchFinished = false

    init() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.hasLaunchFinished = true
        }
    }
}

@main
struct MainNavigationJourney: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var vm = MainNavigationViewModel()
    @StateObject var homeNavigationVm = HomeNavigationViewModel()

    var body: some Scene {
        WindowGroup {
            if vm.hasLaunchFinished {
                TabView(selection: $vm.selectedTab) {
                    Group {
                        homeTab
                        contractsTab

                        let store: ContractStore = globalPresentableStoreContainer.get()
                        if !store.state.activeContracts.allSatisfy({ $0.isNonPayingMember })
                            || store.state.activeContracts.isEmpty
                        {
                            foreverTab
                        }

                        //                if Dependencies.featureFlags().isPaymentScreenEnabled {
                        paymentsTab
                        //                }
                        profileTab
                    }
                }
                .tint(hTextColor.primary)
            } else {
                ProgressView()
            }
        }
    }

    var homeTab: some View {
        let claims = Claims()

        return NavigationStack(path: $homeNavigationVm.externalNavigationRedirect) {
            HomeView(
                claimsContent: claims,
                memberId: {
                    let profileStrore: ProfileStore = globalPresentableStoreContainer.get()
                    return profileStrore.state.memberDetails?.id ?? ""
                }
            )
            .environmentObject(homeNavigationVm)
            .presentModally(
                presented: $homeNavigationVm.isSubmitClaimPresented,
                style: .height,
                content: {
                    HonestyPledge(onConfirmAction: {})
                        .navigationBarTitleDisplayMode(.inline)
                }
            )
            .sheet(isPresented: $homeNavigationVm.isChatPresented) {
                ChatScreen(vm: .init(topicType: nil))
                    .presentationDetents([.large, .medium])
            }
            .sheet(isPresented: $homeNavigationVm.isDocumentPresented) {
                if let document = homeNavigationVm.document, let url = URL(string: document.url) {
                    DocumentRepresentable(document: .init(url: url, title: document.displayName))
                        .presentationDetents([.large, .medium])
                }
            }
            .sheet(isPresented: $homeNavigationVm.navBarItems.isFirstVetPresented) {
                let store: HomeStore = globalPresentableStoreContainer.get()
                if let hasVetPartners = store.state.quickActions.getFirstVetPartners {
                    FirstVetView(partners: hasVetPartners)
                        .presentationDetents([.large])
                }
            }
            .sheet(isPresented: $homeNavigationVm.navBarItems.isNewOfferPresented) {
                CrossSellingScreen()
                    .presentationDetents([.medium])
            }
            .sheet(isPresented: $homeNavigationVm.isCoInsuredPresented) {
                let contractStore: ContractStore = globalPresentableStoreContainer.get()

                let contractsSupportingCoInsured = contractStore.state.activeContracts
                    .filter({ $0.showEditCoInsuredInfo })
                    .compactMap({
                        InsuredPeopleConfig(contract: $0)
                    })

                EditCoInsuredViewJourney(configs: contractsSupportingCoInsured)
                    .presentationDetents([.large, .medium])
            }
            .navigationDestination(for: ClaimModel.self) { claim in
                ClaimDetailView(claim: claim)
                    .environmentObject(homeNavigationVm)
            }
            .fullScreenCover(
                isPresented: $homeNavigationVm.isHelpCenterPresented,
                content: {
                    HelpCenterStartView()
                        .environmentObject(homeNavigationVm)
                }
            )
        }
        .tabItem {
            Image(uiImage: vm.selectedTab == 0 ? hCoreUIAssets.homeTabActive.image : hCoreUIAssets.homeTab.image)
            hText(L10n.tabHomeTitle)
        }
        .tag(0)
    }

    var contractsTab: some View {
        Contracts(showTerminated: false)
            .tabItem {
                Image(
                    uiImage: vm.selectedTab == 1
                        ? hCoreUIAssets.contractTabActive.image : hCoreUIAssets.contractTab.image
                )
                hText(L10n.tabInsurancesTitle)
            }
            .tag(1)
    }

    var foreverTab: some View {
        ForeverView()
            .tabItem {
                Image(
                    uiImage: vm.selectedTab == 2 ? hCoreUIAssets.foreverTabActive.image : hCoreUIAssets.foreverTab.image
                )
                hText(L10n.tabReferralsTitle)
            }
            .tag(2)
    }

    var paymentsTab: some View {
        PaymentsView()
            .tabItem {
                Image(
                    uiImage: vm.selectedTab == 3
                        ? hCoreUIAssets.paymentsTabActive.image : hCoreUIAssets.paymentsTab.image
                )
                hText(L10n.tabPaymentsTitle)
            }
            .tag(3)
    }

    var profileTab: some View {
        ProfileView()
            .tabItem {
                Image(
                    uiImage: vm.selectedTab == 4 ? hCoreUIAssets.profileTabActive.image : hCoreUIAssets.profileTab.image
                )
                hText(L10n.ProfileTab.title)
            }
            .tag(4)
    }
}
#Preview{
    Launch()
}

struct ContentSizeModifier<SwiftUIContent>: ViewModifier where SwiftUIContent: View {

    @Binding var presented: Bool
    @State private var height: CGFloat = 0
    @State private var detents: Set<PresentationDetent> = []
    @State private var selected: PresentationDetent
    @StateObject private var vm = ContentSizeModifierViewModel()
    let content: SwiftUIContent
    private let style: DetentPresentationStyle

    init(
        presented: Binding<Bool>,
        style: DetentPresentationStyle,
        @ViewBuilder content: @escaping () -> SwiftUIContent
    ) {
        _presented = presented
        self.content = content()

        var startDetents = Set<PresentationDetent>()
        if style.contains(.medium) {
            startDetents.insert(.medium)
        }
        if style.contains(.large) {
            startDetents.insert(.large)
        }

        if style.contains(.height) {
            startDetents.insert(.height(0))
        }
        self._detents = State(initialValue: startDetents)
        self._selected = State(initialValue: startDetents.first!)
        self.style = style
    }

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $presented) {
                self.content
                    .presentationDetents(detents, selection: $selected)
                    .onChange(of: height) { newValue in
                        handleOnHeightChange(height: newValue)
                    }
                    .introspectScrollView { scrollView in
                        handleScrollView(scrollView: scrollView)
                    }

            }
            .onChange(of: presented) { newValue in
                if !presented {
                    vm.observer = nil
                }
            }
    }

    private func handleScrollView(scrollView: UIScrollView) {
        if self.style.contains(.height) {
            let scrollViewHeight = scrollView.contentSize.height
            let navBarHeight: CGFloat = {
                if scrollView.viewController?.navigationController?.isNavigationBarHidden == true {
                    return 0
                }
                return scrollView.viewController?.navigationController?.navigationBar.frame.size.height ?? 0
            }()
            DispatchQueue.main.async { [weak scrollView, weak vm] in guard let scrollView = scrollView else { return }
                vm?.observer = scrollView.observe(\UIScrollView.contentSize) { scrollView, changes in
                    DispatchQueue.main.async { [weak scrollView] in guard let scrollView = scrollView else { return }
                        withAnimation(.easeInOut(duration: 1)) {
                            height = scrollView.contentSize.height + navBarHeight
                        }
                    }
                }
                height = scrollViewHeight + navBarHeight
                scrollView.bounces = false
            }
        }
    }

    private func handleOnHeightChange(height: CGFloat) {
        let detent = detents.first { detent in
            detent != .medium || detent != .large
        }
        if !detents.contains(.height(height)) {
            detents.insert(.height(height))
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            selected = .height(height)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if let detent {
                detents.remove(detent)
            }
        }
    }
}

class ContentSizeModifierViewModel: ObservableObject {
    weak var observer: NSKeyValueObservation?
}

extension View {
    func presentModally<SwiftUIContent: View>(
        presented: Binding<Bool>,
        style: DetentPresentationStyle,
        content: @escaping () -> SwiftUIContent
    ) -> some View {
        modifier(ContentSizeModifier(presented: presented, style: style, content: content))
    }
}

struct DetentPresentationStyle: OptionSet {
    let rawValue: UInt

    static let medium = DetentPresentationStyle(rawValue: 1 << 0)
    static let large = DetentPresentationStyle(rawValue: 1 << 1)
    static let height = DetentPresentationStyle(rawValue: 1 << 2)
}

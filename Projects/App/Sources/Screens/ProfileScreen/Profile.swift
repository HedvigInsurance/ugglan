import Apollo
import Flow
import Form
import Presentation
import SwiftUI
import UIKit
import hAnalytics
import hCore
import hCoreUI
import hGraphQL

struct ProfileRow: View {
    let title: String
    let subtitle: String?
    let icon: UIImage
    let onTap: () -> Void
    
    public var body: some View {
        hRow {
            HStack(spacing: 16) {
                Image(uiImage: icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
                VStack(alignment: .leading, spacing: 2) {
                    hText(title)
                    if let subtitle = subtitle {
                        hText(subtitle, style: .footnote).foregroundColor(hLabelColor.secondary)
                    }
                }
            }.padding(0)
        }
        .withCustomAccessory({
            Spacer()
            StandaloneChevronAccessory()
        })
        .verticalPadding(12)
        .onTap {
            onTap()
        }
    }
}

struct ProfileView: View {
    @PresentableStore var store: ProfileStore
    //@State private var showLogoutAlert = false
    
    private func getLogoutIcon() -> UIImage {
        let icon = Asset.logoutIcon.image.withTintColor(.brand(.destructive))
        return icon
    }
    
    /*private var logoutAlert: SwiftUI.Alert {
        return Alert(
            title: Text(L10n.logoutAlertTitle),
            message: nil,
            primaryButton: .cancel(Text(L10n.logoutAlertActionCancel)),
            secondaryButton: .destructive(Text(L10n.logoutAlertActionConfirm)) {
                store.send(.logout)
            }
        )
    }*/
    
    public var body: some View {
        hForm(gradientType: .profile) {
            PresentableStoreLens(
                ProfileStore.self,
                getter: { state in
                    state
                }
            ) { stateData in
                hSection {
                    ProfileRow(
                        title: L10n.profileMyInfoRowTitle,
                        subtitle: stateData.memberFullName,
                        icon: Asset.myInfoRowIcon.image
                    ) {
                        store.send(.openProfile)
                    }
                    if hAnalyticsExperiment.showCharity {
                        ProfileRow(
                            title: L10n.profileMyCharityRowTitle,
                            subtitle: stateData.memberCharityName,
                            icon: Asset.charityPlain.image
                        ) {
                            store.send(.openCharity)
                        }
                    }
                    if hAnalyticsExperiment.paymentScreen {
                        ProfileRow(
                            title: L10n.profilePaymentRowHeader,
                            subtitle: "\(stateData.monthlyNet) \(L10n.paymentCurrencyOccurrence)",
                            icon: Asset.paymentRowIcon.image
                        ) {
                            store.send(.openPayment)
                        }
                    }
                }
                .withoutHorizontalPadding
                .sectionContainerStyle(.transparent)
                hSection {
                    ProfileRow(
                        title: L10n.OnboardingContextualMenu.appInfoLabel,
                        subtitle: nil,
                        icon: Asset.infoIcon.image
                    ) {
                        store.send(.openAppInformation)
                    }
                    ProfileRow(
                        title: L10n.EmbarkOnboardingMoreOptions.settingsLabel,
                        subtitle: nil,
                        icon: Asset.settingsIcon.image
                    ) {
                        store.send(.openAppSettings)
                    }
                    hRow {
                        HStack(spacing: 16) {
                            Image(uiImage: Asset.logoutIcon.image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 40, height: 40)
                                .foregroundColor(Color(.brand(.destructive)))
                            VStack(alignment: .leading, spacing: 2) {
                                hText(L10n.logoutButton).foregroundColor(Color(.brand(.destructive)))
                            }
                            
                        }.padding(0)
                    }
                    .withCustomAccessory({
                        Spacer()
                    })
                    .verticalPadding(12)
                    .onTap {
                        //showLogoutAlert = true
                        store.send(.logout)
                    }
                }
                .withHeader {
                    hText(
                        L10n.Profile.AppSettingsSection.title,
                        style: .title2
                    ).padding(.leading, 16)
                }
                .withoutHorizontalPadding
                .sectionContainerStyle(.transparent)
                
            }.presentableStoreLensAnimation(.spring())
        }.onAppear {
            store.send(.fetchProfileState)
        }
    }
}

public enum ProfileResult {
    case openPayment
    case logout
}

extension ProfileView {
    public static func journey<ResultJourney: JourneyPresentation>(
        @JourneyBuilder resultJourney: @escaping (_ result: ProfileResult) -> ResultJourney
    ) -> some JourneyPresentation {
        HostingJourney(
            ProfileStore.self,
            rootView: ProfileView(),
            options: [
                .defaults,
                .prefersLargeTitles(true),
                .largeTitleDisplayMode(.always),
            ]
        ) { action in
            if case .openProfile = action {
                Journey(
                    MyInfo(),
                    options: [.defaults, .prefersLargeTitles(false), .largeTitleDisplayMode(.never)]
                )
            } else if case .openCharity = action {
                Journey(
                    Charity(),
                    options: [.defaults, .prefersLargeTitles(false), .largeTitleDisplayMode(.never)]
                )
            } else if case .openPayment = action {
                resultJourney(.openPayment)
            } else if case .openAppInformation = action {
                Journey(
                    AppInfo(type: .appInformation),
                    options: [.defaults, .prefersLargeTitles(false), .largeTitleDisplayMode(.never)]
                )
            } else if case .openAppSettings = action {
                Journey(
                    AppInfo(type: .appSettings),
                    options: [.defaults, .prefersLargeTitles(false), .largeTitleDisplayMode(.never)]
                )
            } else if case .logout = action {
                resultJourney(.logout)
            }
        }
        .configureTitle(L10n.profileTitle)
        .addConfiguration({ presenter in
            // - TODO - refactor
            let tabBarItem = UITabBarItem(
                title: L10n.profileTitle,
                image: Asset.profileTab.image,
                selectedImage: Asset.profileTabActive.image
            )
            presenter.viewController.tabBarItem = tabBarItem
        })
    }
}

public struct ProfileRepresentable: UIViewControllerRepresentable {
    public init() {}

    public class Coordinator {
        let bag = DisposeBag()
        let profileView: Profile

        init() {
            self.profileView = Profile()
        }
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    public func makeUIViewController(context: Context) -> UIViewController {
        let (vc, disposable) = context.coordinator.profileView.materialize()
        context.coordinator.bag += DisposeOnMain(disposable)
        vc.view.backgroundColor = .clear
        return vc
    }

    public func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}

struct Profile { @Inject var client: ApolloClient }

extension Profile: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let bag = DisposeBag()

        let viewController = UIViewController()
        viewController.displayableTitle = L10n.profileTitle
        viewController.installChatButton()

        let form = FormView()

        let profileSection = ProfileSection(presentingViewController: viewController)

        bag += form.append(profileSection)

        bag += form.append(Spacing(height: 20))

        let settingsSection = SettingsSection(presentingViewController: viewController)
        bag += form.append(settingsSection)

        form.appendSpacing(.custom(20))

        let query = GraphQL.ProfileQuery()

        bag += client.watch(query: query).bindTo(profileSection.dataSignal)

        bag += viewController.install(form) { scrollView in
            let refreshControl = UIRefreshControl()
            bag += self.client.refetchOnRefresh(query: query, refreshControl: refreshControl)

            scrollView.refreshControl = refreshControl
            bag += scrollView.chainAllControlResponders(shouldLoop: true, returnKey: .next)
        }

        viewController.trackOnAppear(hAnalyticsEvent.screenView(screen: .profile))

        return (viewController, bag)
    }
}

extension Profile: Tabable {
    func tabBarItem() -> UITabBarItem {
        UITabBarItem(
            title: L10n.tabProfileTitle,
            image: Asset.profileTab.image,
            selectedImage: Asset.profileTabActive.image
        )
    }
}

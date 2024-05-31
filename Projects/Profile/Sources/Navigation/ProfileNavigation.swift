import SwiftUI
import hCore
import hCoreUI

public class ProfileNavigationViewModel: ObservableObject {
    @Published public var isDeleteAccountPresented: MemberDetails?
    @Published var isDeleteAccountAlreadyRequestedPresented = false
    @Published public var isLanguagePickerPresented = false

    public let profileRouter = Router()

    public init() {}
}

public enum ProfileNavigationDismissAction {
    case openChat
    case makeHomeTabActive
    case makeHomeTabActiveAndOpenChat
}

public struct ProfileNavigation<Content: View>: View {
    @ViewBuilder var redirect: (_ type: ProfileRedirectType) -> Content
    @ObservedObject var profileNavigationViewModel: ProfileNavigationViewModel

    public init(
        profileNavigationViewModel: ProfileNavigationViewModel,
        @ViewBuilder redirect: @escaping (_ type: ProfileRedirectType) -> Content
    ) {
        self.profileNavigationViewModel = profileNavigationViewModel
        self.redirect = redirect
    }

    public var body: some View {
        RouterHost(router: profileNavigationViewModel.profileRouter) {
            ProfileView()
                .routerDestination(for: ProfileRedirectType.self) { redirectType in
                    switch redirectType {
                    case .travelCertificate:
                        redirect(.travelCertificate)
                    case .myInfo:
                        MyInfoView()
                            .configureTitle(L10n.profileMyInfoRowTitle)
                    case .appInfo:
                        AppInfoView()
                            .configureTitle(L10n.profileAppInfo)
                    case .settings:
                        SettingsScreen()
                            .configureTitle(L10n.EmbarkOnboardingMoreOptions.settingsLabel)
                    case .euroBonus:
                        EuroBonusNavigation(useOwnNavigation: false)
                    default:
                        EmptyView()
                    }
                }
        }
        .environmentObject(profileNavigationViewModel)
        .detent(
            item: $profileNavigationViewModel.isDeleteAccountPresented,
            style: .height,
            options: .constant(.withoutGrabber)
        ) { memberDetails in
            redirect(
                .deleteAccount(
                    memberDetails: memberDetails
                )
            )
        }
        .detent(
            presented: $profileNavigationViewModel.isLanguagePickerPresented,
            style: .height,
            content: {
                redirect(.pickLanguage)
                    .configureTitle(L10n.MarketLanguageScreen.chooseLanguageLabel)
                    .embededInNavigation(options: .navigationType(type: .large))
            }
        )
        .fullScreenCover(
            isPresented: $profileNavigationViewModel.isDeleteAccountAlreadyRequestedPresented
        ) {
            redirect(.deleteRequestLoading)
        }
    }
}

public enum ProfileRedirectType: Hashable {
    case travelCertificate
    case myInfo
    case appInfo
    case settings
    case euroBonus
    case deleteAccount(memberDetails: MemberDetails)
    case deleteRequestLoading
    case pickLanguage
    case editCoInsured(config: InsuredPeopleConfig)
}

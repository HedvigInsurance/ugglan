import SwiftUI
import hCore
import hCoreUI

public class ProfileNavigationViewModel: ObservableObject {
    @Published var isDeleteAccountPresented: MemberDetails?
    @Published var isDeleteAccountAlreadyRequestedPresented = false
    @Published var isLanguagePickerPresnted = false
}

public enum ProfileNavigationDismissAction {
    case openChat
}

public struct ProfileNavigation<Content: View>: View {
    @ViewBuilder var redirect: (_ type: ProfileRedirectType) -> Content
    @StateObject var router = Router()
    @StateObject var profileNavigationViewModel = ProfileNavigationViewModel()

    public init(@ViewBuilder redirect: @escaping (_ type: ProfileRedirectType) -> Content) {
        self.redirect = redirect
    }

    public var body: some View {
        RouterHost(router: router) {
            ProfileView()
                .routerDestination(for: ProfileRedirectType.self) { redirectType in
                    switch redirectType {
                    case .travelCertificate:
                        redirect(.travelCertificate)
                    case .myInfo:
                        MyInfoView()
                    case .appInfo:
                        AppInfoView()
                    case .settings:
                        SettingsScreen()
                    case .euroBonus:
                        EuroBonusNavigation()
                    case .deleteAccount:
                        EmptyView()
                    case .pickLanguage:
                        EmptyView()
                    }
                }
        }
        .environmentObject(router)
        .environmentObject(profileNavigationViewModel)
        .detent(
            item: $profileNavigationViewModel.isDeleteAccountPresented,
            style: .height,
            options: .constant(.withoutGrabber)
        ) { memberDetails in
            redirect(
                .deleteAccount(
                    memberDetails: memberDetails
                        //                onDismiss: {
                        //                    profileNavigationViewModel.isDeleteAccountPresented = nil
                        //                }
                )
            )
        }
        .detent(
            presented: $profileNavigationViewModel.isLanguagePickerPresnted,
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
            DeleteRequestLoadingView(screenState: .success)
            environmentObject(profileNavigationViewModel)
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
    case pickLanguage
}

import EditCoInsured
import InsuranceEvidence
import Market
import SwiftUI
import TravelCertificate
import hCore
import hCoreUI

@MainActor
public class ProfileNavigationViewModel: ObservableObject {
    @Published public var isDeleteAccountPresented: MemberDetails?
    @Published var isDeleteAccountAlreadyRequestedPresented = false
    @Published public var isLanguagePickerPresented = false
    @Published public var isConfirmEmailPreferencesPresented = false
    @Published public var isCreateInsuranceEvidencePresented = false
    let travelCertificateNavigationViewModel = TravelCertificateNavigationViewModel()
    public let profileRouter = Router()

    public func pushToProfile() {
        Task {
            self.profileRouter.push(ProfileRouterType.myInfo)
        }
    }

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
        RouterHost(router: profileNavigationViewModel.profileRouter, tracking: ProfileDetentType.profile) {
            ProfileView()
                .routerDestination(for: ProfileRouterType.self) { redirectType in
                    switch redirectType {
                    case .myInfo:
                        MyInfoView()
                            .configureTitle(L10n.profileMyInfoRowTitle)
                    case .appInfo:
                        AppInfoView()
                            .configureTitle(L10n.profileAppInfo)
                    case .settings:
                        SettingsView()
                            .configureTitle(L10n.EmbarkOnboardingMoreOptions.settingsLabel)
                    case .euroBonus:
                        EuroBonusNavigation(useOwnNavigation: false)
                    case .certificates:
                        CertificatesScreen()
                            .configureTitle(L10n.Profile.Certificates.title)
                            .environmentObject(profileNavigationViewModel)
                    }
                }
                .routerDestination(for: ProfileRedirectType.self) { redirectType in
                    switch redirectType {
                    case .travelCertificate:
                        TravelCertificateNavigation(
                            vm: profileNavigationViewModel.travelCertificateNavigationViewModel,
                            infoButtonPlacement: .trailing,
                            useOwnNavigation: false
                        )
                    default:
                        EmptyView()
                    }
                }
        }
        .environmentObject(profileNavigationViewModel)
        .detent(
            item: $profileNavigationViewModel.isDeleteAccountPresented,

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

            content: {
                redirect(.pickLanguage)
                    .configureTitle(L10n.MarketLanguageScreen.chooseLanguageLabel)
                    .embededInNavigation(
                        options: .navigationType(type: .large),
                        tracking: ProfileDetentType.languagePicker
                    )
            }
        )
        .modally(
            presented: $profileNavigationViewModel.isDeleteAccountAlreadyRequestedPresented,
            tracking: ProfileRedirectType.deleteRequestLoading
        ) {
            redirect(.deleteRequestLoading)
        }
        .modally(presented: $profileNavigationViewModel.isCreateInsuranceEvidencePresented) {
            InsuranceEvidenceNavigation()
        }
    }
}

public enum ProfileRouterType: Hashable {
    case myInfo
    case appInfo
    case settings
    case euroBonus
    case certificates
}

enum ProfileDetentType: TrackingViewNameProtocol {
    var nameForTracking: String {
        switch self {
        case .profile:
            return .init(describing: ProfileView.self)
        case .languagePicker:
            return .init(describing: LanguagePickerView.self)
        case .emailPreferences:
            return .init(describing: EmailPreferencesConfirmView.self)
        }
    }

    case profile
    case languagePicker
    case emailPreferences
}

extension ProfileRouterType: TrackingViewNameProtocol {
    public var nameForTracking: String {
        switch self {
        case .myInfo:
            return .init(describing: MyInfoView.self)
        case .appInfo:
            return .init(describing: AppInfoView.self)
        case .settings:
            return .init(describing: SettingsView.self)
        case .euroBonus:
            return .init(describing: EuroBonusView.self)
        case .certificates:
            return .init(describing: CertificatesScreen.self)
        }
    }
}

public enum ProfileRedirectType: Hashable {
    case travelCertificate
    case deleteAccount(memberDetails: MemberDetails)
    case deleteRequestLoading
    case pickLanguage
}

extension ProfileRedirectType: TrackingViewNameProtocol {
    public var nameForTracking: String {
        switch self {
        case .travelCertificate:
            return "List screen"
        case .deleteAccount:
            return .init(describing: DeleteAccountView.self)
        case .deleteRequestLoading:
            return .init(describing: DeleteRequestLoadingView.self)
        case .pickLanguage:
            return .init(describing: LanguagePickerView.self)
        }
    }
}

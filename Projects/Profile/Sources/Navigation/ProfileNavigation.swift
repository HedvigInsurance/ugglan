import Claims
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
                    case .appInfo:
                        AppInfoView()
                    case .settings:
                        SettingsView()
                    case .euroBonus:
                        EuroBonusNavigation(useOwnNavigation: false)
                    case .certificates:
                        CertificatesScreen()
                            .environmentObject(profileNavigationViewModel)
                    case .claimHistory:
                        ClaimHistoryScreen { claim in
                            profileNavigationViewModel.profileRouter.push(
                                ProfileRouterTypeWithHiddenBottomBar.claimsCard(claim: claim)
                            )
                        }
                    case .travelCertificates:
                        TravelCertificateNavigation(
                            vm: profileNavigationViewModel.travelCertificateNavigationViewModel,
                            infoButtonPlacement: .trailing,
                            useOwnNavigation: false
                        )
                    }
                }
                .routerDestination(
                    for: ProfileRouterTypeWithHiddenBottomBar.self,
                    options: [.hidesBottomBarWhenPushed]
                ) { redirectType in
                    switch redirectType {
                    case let .claimsCard(claim):
                        ClaimDetailView(claim: claim, type: .claim(id: claim.id))
                            .configureTitle(L10n.claimsYourClaim)
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
    case claimHistory
    case travelCertificates
}

public enum ProfileRouterTypeWithHiddenBottomBar: Hashable {
    case claimsCard(claim: ClaimModel)
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
        case .claimHistory:
            return .init(describing: ClaimHistoryScreen.self)
        case .travelCertificates:
            return .init(describing: TravelCertificatesListScreen.self)
        }
    }
}

extension ProfileRouterType: NavigationTitleProtocol {
    public var navigationTitle: String? {
        switch self {
        case .myInfo:
            L10n.profileMyInfoRowTitle
        case .appInfo:
            L10n.profileAppInfo
        case .settings:
            L10n.EmbarkOnboardingMoreOptions.settingsLabel
        case .euroBonus:
            L10n.SasIntegration.title
        case .certificates:
            L10n.Profile.Certificates.title
        case .claimHistory:
            L10n.Profile.ClaimHistory.title
        case .travelCertificates:
            L10n.TravelCertificate.cardTitle
        }
    }
}

extension ProfileRouterTypeWithHiddenBottomBar: TrackingViewNameProtocol {
    public var nameForTracking: String {
        switch self {
        case .claimsCard:
            return .init(describing: ClaimsCard.self)
        }
    }
}

public enum ProfileRedirectType: Hashable {
    case deleteAccount(memberDetails: MemberDetails)
    case deleteRequestLoading
    case pickLanguage
    case travelCertificate
}

extension ProfileRedirectType: TrackingViewNameProtocol {
    public var nameForTracking: String {
        switch self {
        case .deleteAccount:
            return .init(describing: DeleteAccountView.self)
        case .deleteRequestLoading:
            return .init(describing: DeleteRequestLoadingView.self)
        case .pickLanguage:
            return .init(describing: LanguagePickerView.self)
        case .travelCertificate:
            return L10n.TravelCertificate.cardTitle
        }
    }
}

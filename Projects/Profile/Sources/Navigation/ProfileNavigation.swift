import EditCoInsuredShared
import Market
import SwiftUI
import hCore
import hCoreUI

public class ProfileNavigationViewModel: ObservableObject {
    @Published public var isDeleteAccountPresented: MemberDetails?
    @Published var isDeleteAccountAlreadyRequestedPresented = false
    @Published public var isLanguagePickerPresented = false

    @Published public var isEditCoInsuredSelectContractPresented: CoInsuredConfigModel?
    @Published public var isEditCoInsuredPresented: InsuredPeopleConfig?

    @Published public var isConfirmEmailPreferencesPresented = false

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
                    }
                }
                .routerDestination(for: ProfileRedirectType.self) { redirectType in
                    switch redirectType {
                    case .travelCertificate:
                        redirect(.travelCertificate)
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
        .detent(
            item: $profileNavigationViewModel.isEditCoInsuredSelectContractPresented,
            style: .height
        ) { configs in
            redirect(
                .editCoInuredSelectInsurance(
                    configs: configs.configs
                )
            )
        }
        .fullScreenCover(
            item: $profileNavigationViewModel.isEditCoInsuredPresented
        ) { config in
            getEditCoInsuredView(config: config)
        }
    }

    private func getEditCoInsuredView(config: InsuredPeopleConfig) -> some View {
        redirect(
            .editCoInsured(config: config)
        )
    }
}

public enum ProfileRouterType: Hashable {
    case myInfo
    case appInfo
    case settings
    case euroBonus
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
        }
    }
}

public enum ProfileRedirectType: Hashable {
    case travelCertificate
    case deleteAccount(memberDetails: MemberDetails)
    case deleteRequestLoading
    case pickLanguage
    case editCoInsured(config: InsuredPeopleConfig)
    case editCoInuredSelectInsurance(configs: [InsuredPeopleConfig])
}

extension ProfileRedirectType: TrackingViewNameProtocol {
    public var nameForTracking: String {
        switch self {
        case .travelCertificate:
            return "List screen"
        case .deleteAccount(let memberDetails):
            return .init(describing: DeleteAccountView.self)
        case .deleteRequestLoading:
            return .init(describing: DeleteRequestLoadingView.self)
        case .pickLanguage:
            return .init(describing: PickLanguage.self)
        case .editCoInsured(let config):
            return "Edit co inusred"
        case .editCoInuredSelectInsurance(let configs):
            return "Edit co inusred"
        }
    }

}

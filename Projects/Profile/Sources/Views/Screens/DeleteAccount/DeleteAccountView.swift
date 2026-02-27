import PresentableStore
import SwiftUI
import hCore
import hCoreUI

public struct DeleteAccountView: View {
    @ObservedObject var vm: DeleteAccountViewModel
    @StateObject var router = NavigationRouter()
    @EnvironmentObject var profileNavigationVm: ProfileNavigationViewModel
    let memberDetails: MemberDetails?
    public init(
        vm: DeleteAccountViewModel
    ) {
        let store: ProfileStore = globalPresentableStoreContainer.get()
        self.memberDetails = store.state.memberDetails
        self.vm = vm
    }

    public var body: some View {
        hNavigationStack(
            router: router,
            options: .extendedNavigationWidth,
            tracking: DeleteDetentType.deleteAccountView
        ) {
            hForm {
                hSection {
                    VStack(alignment: vm.alignment, spacing: vm.titleAndDescriptionSpacing) {
                        if let topIcon = vm.topIcon {
                            topIcon
                                .foregroundColor(hSignalColor.Amber.element)
                                .padding(.bottom, .padding16)
                        }
                        hText(vm.title)
                        MarkdownView(
                            config: .init(
                                text: vm.text,
                                fontStyle: .body1,
                                color: hTextColor.Opaque.secondary,
                                linkColor: hTextColor.Opaque.primary,
                                linkUnderlineStyle: .single,
                                textAlignment: vm.textAlignment,
                                isSelectable: false
                            ) { url in
                                NotificationCenter.default.post(name: .openDeepLink, object: url)
                            }
                        )
                    }
                }
                .sectionContainerStyle(.transparent)
            }
            .hFormContentPosition(.compact)
            .hFormAttachToBottom {
                hSection {
                    VStack(spacing: .padding8) {
                        if !vm.hasActiveClaims, !vm.hasActiveContracts {
                            hButton(
                                .large,
                                .alert,
                                content: .init(title: L10n.profileDeleteAccountConfirmDeletion),
                                {
                                    profileNavigationVm.isDeleteAccountRequestedPresented = memberDetails
                                }
                            )
                        }
                        hButton(
                            .large,
                            .ghost,
                            content: .init(title: vm.dismissButtonTitle),
                            {
                                router.dismiss()
                            }
                        )
                    }
                    .padding(.vertical, .padding16)
                }
                .sectionContainerStyle(.transparent)
            }
        }
    }
}

private enum DeleteDetentType: TrackingViewNameProtocol {
    var nameForTracking: String {
        switch self {
        case .deleteAccountView:
            return .init(describing: DeleteAccountView.self)
        }
    }

    case deleteAccountView
}

extension DeleteAccountViewModel {
    var title: String {
        if hasActiveContracts {
            return L10n.DeleteAccount.youHaveActiveInsuranceTitle
        } else if hasActiveClaims {
            return L10n.DeleteAccount.youHaveActiveClaimTitle
        } else {
            return L10n.DeleteAccount.deleteAccountTitle
        }
    }

    var text: String {
        if hasActiveContracts {
            return L10n.DeleteAccount.youHaveActiveInsuranceDescription
        } else if hasActiveClaims {
            return L10n.DeleteAccount.youHaveActiveClaimDescription
        } else {
            return L10n.DeleteAccount.deleteAccountDescription
        }
    }

    var alignment: HorizontalAlignment {
        if hasActiveContracts {
            return .center
        } else if hasActiveClaims {
            return .center
        } else {
            return .leading
        }
    }

    var titleAndDescriptionSpacing: CGFloat {
        if hasActiveContracts {
            return 0
        } else if hasActiveClaims {
            return 0
        } else {
            return 8
        }
    }

    var topIcon: Image? {
        if hasActiveContracts {
            return hCoreUIAssets.warningTriangleFilled.view
        } else if hasActiveClaims {
            return hCoreUIAssets.warningTriangleFilled.view
        } else {
            return nil
        }
    }

    var textAlignment: NSTextAlignment {
        if hasActiveContracts {
            return .center
        } else if hasActiveClaims {
            return .center
        } else {
            return .left
        }
    }

    var dismissButtonTitle: String {
        if hasActiveContracts {
            return L10n.generalCloseButton
        } else if hasActiveClaims {
            return L10n.generalCloseButton
        } else {
            return L10n.generalCancelButton
        }
    }
}

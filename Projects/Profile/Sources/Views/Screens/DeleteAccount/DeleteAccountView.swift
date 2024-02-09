import Claims
import Contracts
import Presentation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct DeleteAccountView: View {
    @ObservedObject var vm: DeleteAccountViewModel
    var body: some View {
        hForm {
            Spacing(height: vm.topSpacing)
            hSection {
                VStack(alignment: vm.alignment, spacing: vm.titleAndDescriptionSpacing) {
                    if let topIcon = vm.topIcon {
                        Image(uiImage: topIcon)
                            .foregroundColor(hSignalColor.amberElement)
                            .padding(.bottom, 16)
                    }
                    hText(vm.title)
                    MarkdownView(
                        config: .init(
                            text: vm.text,
                            fontStyle: .standard,
                            color: hTextColor.secondary,
                            linkColor: hTextColor.primary,
                            linkUnderlineStyle: .single,
                            textAlignment: vm.textAlignment
                        ) { url in
                            let store: ProfileStore = globalPresentableStoreContainer.get()
                            store.send(.goToURL(url: url))
                        }
                    )
                }
            }
            .sectionContainerStyle(.transparent)
        }
        .hFormAttachToBottom {
            hSection {
                VStack(spacing: 8) {
                    if !vm.hasActiveClaims && !vm.hasActiveContracts {
                        hButton.LargeButton(type: .alert) { [weak vm] in
                            vm?.deleteAccount()
                        } content: {
                            hText(L10n.profileDeleteAccountConfirmDeletion)
                        }
                    }
                    hButton.LargeButton(type: .ghost) {
                        let store: ProfileStore = globalPresentableStoreContainer.get()
                        store.send(.dismissScreen(openChatAfter: false))
                    } content: {
                        hText(vm.dismissButtonTitle)
                    }
                }
                .padding(.vertical, 16)
            }
            .sectionContainerStyle(.transparent)
        }
        .onAppear {
            for i in 0...10 {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.05) {
                    if #available(iOS 15.0, *) {
                        if #available(iOS 16.0, *) {
                            UIApplication.shared.getTopViewController()?.sheetPresentationController?
                                .animateChanges {
                                    UIApplication.shared.getTopViewController()?.sheetPresentationController?
                                        .invalidateDetents()
                                }
                        } else {
                            UIApplication.shared.getTopViewController()?.sheetPresentationController?
                                .animateChanges {

                                }
                        }
                    }
                }
            }
        }
    }
}

struct ParagraphTextModifier<Color: hColor>: ViewModifier {
    var color: Color

    func body(content: Content) -> some View {
        content
            .fixedSize(horizontal: false, vertical: true)
            .foregroundColor(color)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

extension DeleteAccountView {
    static func deleteAccountJourney(details: MemberDetails) -> some JourneyPresentation {
        let claimsStore: ClaimsStore = globalPresentableStoreContainer.get()
        let contractsStore: ContractStore = globalPresentableStoreContainer.get()
        let model = DeleteAccountViewModel(
            memberDetails: details,
            claimsStore: claimsStore,
            contractsStore: contractsStore
        )
        let style: PresentationStyle = .detented(.scrollViewContentSize)
        return HostingJourney(
            ProfileStore.self,
            rootView: DeleteAccountView(
                vm: model
            ),
            style: style,
            options: [.blurredBackground]
        ) { action in
            if case let .sendAccountDeleteRequest(memberDetails) = action {
                sendAccountDeleteRequestJourney(details: memberDetails)
            } else if case let .dismissScreen(openChatAfter) = action {
                PopJourney()
                    .onPresent {
                        if openChatAfter {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                let store: ProfileStore = globalPresentableStoreContainer.get()
                                store.send(.openChat)
                            }
                        }
                    }
            }
        }
    }

    static func sendAccountDeleteRequestJourney(details: MemberDetails) -> some JourneyPresentation {
        HostingJourney(
            ProfileStore.self,
            rootView: DeleteRequestLoadingView(screenState: .tryToDelete(with: details))
        ) { action in
            if case .makeTabActive = action {
                DismissJourney()
            }
        }
        .hidesBackButton
    }

    static var deleteRequestAlreadyPlacedJourney: some JourneyPresentation {
        HostingJourney(
            ProfileStore.self,
            rootView: DeleteRequestLoadingView(screenState: .success),
            style: .modally(presentationStyle: .fullScreen)
        ) { action in
            if case .makeTabActive = action {
                PopJourney()
            }
        }
    }
}

extension DeleteAccountViewModel {
    var title: String {
        if self.hasActiveContracts {
            return L10n.DeleteAccount.youHaveActiveInsuranceTitle
        } else if self.hasActiveClaims {
            return L10n.DeleteAccount.youHaveActiveClaimTitle
        } else {
            return L10n.DeleteAccount.deleteAccountTitle
        }
    }
    var text: String {
        if self.hasActiveContracts {
            return L10n.DeleteAccount.youHaveActiveInsuranceDescription
        } else if self.hasActiveClaims {
            return L10n.DeleteAccount.youHaveActiveClaimDescription
        } else {
            return L10n.DeleteAccount.deleteAccountDescription
        }
    }

    var alignment: HorizontalAlignment {
        if self.hasActiveContracts {
            return .center
        } else if self.hasActiveClaims {
            return .center
        } else {
            return .leading
        }
    }
    var topSpacing: Float {
        if self.hasActiveContracts {
            return 64
        } else if self.hasActiveClaims {
            return 64
        } else {
            return 32
        }
    }

    var titleAndDescriptionSpacing: CGFloat {
        if self.hasActiveContracts {
            return 0
        } else if self.hasActiveClaims {
            return 0
        } else {
            return 8
        }
    }

    var topIcon: UIImage? {
        if self.hasActiveContracts {
            return hCoreUIAssets.warningTriangleFilled.image
        } else if self.hasActiveClaims {
            return hCoreUIAssets.warningTriangleFilled.image
        } else {
            return nil
        }
    }

    var textAlignment: NSTextAlignment {
        if self.hasActiveContracts {
            return .center
        } else if self.hasActiveClaims {
            return .center
        } else {
            return .left
        }
    }

    var dismissButtonTitle: String {
        if self.hasActiveContracts {
            return L10n.generalCloseButton
        } else if self.hasActiveClaims {
            return L10n.generalCloseButton
        } else {
            return L10n.generalCancelButton
        }
    }
}

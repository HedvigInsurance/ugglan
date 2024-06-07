import Apollo
import Authentication
import Presentation
import SwiftUI
import hCore
import hCoreUI

public struct AppInfoView: View {
    @State var showSubmitBugAlert = false
    @State var hasPressedSubmitBugOk = false

    public init() {}

    public var body: some View {
        hForm {
            hSection {
                memberId
                profileVersion
                deviceId
            }
            .withoutHorizontalPadding
            .padding(.top, 8)
        }
        .sectionContainerStyle(.transparent)
        .hFormAttachToBottom {
            hSection {
                submitBugButton
            }
            .withoutHorizontalPadding
            .padding(.vertical, 16)
            .sectionContainerStyle(.transparent)
        }
    }

    private var memberId: some View {
        PresentableStoreLens(
            ProfileStore.self,
            getter: { state in
                state
            }
        ) { state in
            let memberId = state.memberDetails?.id
            hRow {
                hText(L10n.profileAboutAppMemberId).foregroundColor(hTextColor.Opaque.primary)
            }
            .noSpacing()
            .withCustomAccessory {
                HStack {
                    Spacer()
                    hText(memberId ?? "").foregroundColor(hTextColor.Opaque.secondary)
                }
            }
            .onTap {
                UIPasteboard.general.value = memberId
                showToaster()
            }
        }
    }

    private var profileVersion: some View {
        let appVersion = Bundle.main.appVersion
        return hRow {
            hText(L10n.profileAboutAppVersion)
                .foregroundColor(hTextColor.Opaque.primary)
        }
        .noSpacing()
        .withCustomAccessory {
            HStack {
                Spacer()
                hText(appVersion)
                    .foregroundColor(hTextColor.Opaque.secondary)
            }
        }
        .onTap {
            UIPasteboard.general.value = appVersion
            showToaster()
        }
    }

    private var deviceId: some View {
        let deviceId = ApolloClient.getDeviceIdentifier()
        return hRow {
            hText(L10n.AppInfo.deviceIdLabel)
                .foregroundColor(hTextColor.Opaque.primary)
        }
        .noSpacing()
        .withCustomAccessory {
            HStack {
                Spacer(minLength: 20)
                hText(deviceId, style: .standardSmall)
                    .minimumScaleFactor(0.2)
                    .lineLimit(1)
                    .foregroundColor(hTextColor.Opaque.secondary)

            }
        }
        .onTap {
            UIPasteboard.general.value = deviceId
            showToaster()
        }
    }

    private var submitBugButton: some View {
        let store: ProfileStore = globalPresentableStoreContainer.get()
        let memberId = store.state.memberDetails?.id ?? ""
        let systemVersion = UIDevice.current.systemVersion
        return OpenEmailClientButton(
            options: EmailOptions(
                recipient: "ios@hedvig.com",
                subject: L10n.AppInfo.SubmitBug.prefilledLetterSubject,
                body: L10n.AppInfo.SubmitBug.prefilledLetterBody(memberId, Bundle.main.appVersion, systemVersion)
            ),
            buttonText: L10n.AppInfo.SubmitBug.button,
            hasAcceptedAlert: $hasPressedSubmitBugOk,
            hasPressedButton: {
                showSubmitBugAlert = true
            },
            buttonSize: .secondary
        )
        .environmentObject(OTPState())
        .alert(isPresented: $showSubmitBugAlert) {
            Alert(
                title: Text(L10n.AppInfo.SubmitBug.warning),
                message: nil,
                primaryButton: .cancel(Text(L10n.alertCancel)),
                secondaryButton: .destructive(Text(L10n.generalContinueButton)) {
                    hasPressedSubmitBugOk = true
                }
            )
        }
    }

    private func showToaster() {
        Toasts.shared.displayToast(
            toast: Toast(
                symbol: .icon(hCoreUIAssets.tick.image),
                body: L10n.General.copied
            )
        )
    }
}

struct AppInfoView_Previews: PreviewProvider {
    static var previews: some View {
        AppInfoView()
            .onAppear {
                let store: ProfileStore = globalPresentableStoreContainer.get()
                store.send(
                    .setMember(
                        memberData: .init(
                            id: "ID",
                            firstName: "FIRST NAME",
                            lastName: "LAST NAME",
                            phone: "PHNE",
                            email: "EMAIL",
                            hasTravelCertificate: true
                        )
                    )
                )
            }
    }
}

import Apollo
import Authentication
import PresentableStore
import SwiftUI
import hCore
import hCoreUI

public struct AppInfoView: View {
    @State var showSubmitBugAlert = false
    @State var hasPressedSubmitBugOk = false
    @StateObject private var vm = AppInfoViewModel()
    public init() {}

    public var body: some View {
        hForm {
            hSection {
                memberId
                profileVersion
                deviceId
            }
            .padding(.top, .padding8)
        }
        .hWithoutHorizontalPadding([.row, .divider])
        .sectionContainerStyle(.transparent)
        .hFormAlwaysAttachToBottom {
            submitBugButton
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
                UIPasteboard.general.string = memberId
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
            UIPasteboard.general.string = appVersion
            showToaster()
        }
    }

    private var deviceId: some View {
        return hRow {
            hText(L10n.AppInfo.deviceIdLabel)
                .foregroundColor(hTextColor.Opaque.primary)
        }
        .noSpacing()
        .withCustomAccessory {
            HStack {
                Spacer(minLength: 20)
                if let deviceId = vm.deviceId {
                    hText(deviceId, style: .label)
                        .minimumScaleFactor(0.2)
                        .lineLimit(1)
                        .foregroundColor(hTextColor.Opaque.secondary)
                }
            }
        }
        .onTap {
            if let deviceId = vm.deviceId {
                UIPasteboard.general.string = deviceId
                showToaster()
            }
        }
        .hRowContentAlignment(.center)
    }

    private var submitBugButton: some View {
        let store: ProfileStore = globalPresentableStoreContainer.get()
        let memberId = store.state.memberDetails?.id ?? ""
        let systemVersion = UIDevice.current.systemVersion
        let deviceId = vm.deviceId ?? "N/A"
        return OpenEmailClientButton(
            options: EmailOptions(
                recipient: "ios@hedvig.com",
                subject: L10n.AppInfo.SubmitBug.prefilledLetterSubject,
                body: L10n.AppInfo.SubmitBug.prefilledLetterBody(
                    memberId,
                    deviceId,
                    Bundle.main.appVersion,
                    systemVersion
                )
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
        Toasts.shared.displayToastBar(
            toast: .init(
                type: .campaign,
                icon: hCoreUIAssets.checkmark.view,
                text: L10n.General.copied
            )
        )
    }
}

@MainActor
class AppInfoViewModel: ObservableObject {
    @Published var deviceId: String?

    init() {
        Task {
            let deviceId = await ApolloClient.getDeviceIdentifier()
            self.deviceId = deviceId
        }
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
                            hasTravelCertificate: true,
                            isContactInfoUpdateNeeded: true
                        )
                    )
                )
            }
    }
}

import Apollo
import Presentation
import SwiftUI
import hCore
import hCoreUI

public struct AppInfoView: View {

    public init() {}

    public var body: some View {
        PresentableStoreLens(
            ProfileStore.self,
            getter: { state in
                state
            }
        ) { state in
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
        }
    }

    private var memberId: some View {
        PresentableStoreLens(
            ProfileStore.self,
            getter: { state in
                state
            }
        ) { state in
            let memberId = state.memberId
            hRow {
                hText(L10n.profileAboutAppMemberId).foregroundColor(hLabelColor.primary)
            }
            .noSpacing()
            .withCustomAccessory {
                HStack {
                    Spacer()
                    hText(memberId).foregroundColor(hLabelColor.secondary)
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
                .foregroundColor(hLabelColor.primary)
        }
        .noSpacing()
        .withCustomAccessory {
            HStack {
                Spacer()
                hText(appVersion)
                    .foregroundColor(hLabelColor.secondary)
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
                .foregroundColor(hLabelColor.primary)
        }
        .noSpacing()
        .withCustomAccessory {
            HStack {
                Spacer(minLength: 20)
                hText(deviceId, style: .standardSmall)
                    .minimumScaleFactor(0.2)
                    .lineLimit(1)
                    .foregroundColor(hLabelColor.secondary)

            }
        }
        .onTap {
            UIPasteboard.general.value = deviceId
            showToaster()
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
                store.send(.setMember(id: "ID", name: "NAME", email: "EMAIL", phone: "PHNE"))
            }
    }
}

extension MenuChildAction {
    static public var appInformation: MenuChildAction {
        MenuChildAction(identifier: "app-information")
    }
}

extension MenuChild {
    public static var appInformation: MenuChild {
        MenuChild(
            title: L10n.aboutScreenTitle,
            style: .default,
            image: hCoreUIAssets.infoIcon.image,
            action: .appInformation
        )
    }
}

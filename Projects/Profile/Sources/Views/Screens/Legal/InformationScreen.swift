import Apollo
import Authentication
import Environment
import PresentableStore
import SwiftUI
import hCore
import hCoreUI

struct InformationScreen: View {
    @State var showSubmitBugAlert = false
    @State var hasPressedSubmitBugOk = false
    @StateObject private var vm = InformationViewModel()

    var body: some View {
        hForm {
            VStack(spacing: .padding24) {
                legalItemsSection
                appInfoItemsSection
            }
            .padding(.top, .padding8)
        }
        .sectionContainerStyle(.transparent)
        .hWithoutHorizontalPadding([.row, .divider])
        .hFormAlwaysAttachToBottom {
            submitBugButton
                .sectionContainerStyle(.transparent)
        }
    }

    private var legalItemsSection: some View {
        hSection(legalItems, id: \.title) { item in
            hRow {
                hText(item.title)
                Spacer()
            }
            .withCustomAccessory {
                hCoreUIAssets.arrowNorthEast.view
            }
            .onTap {
                Dependencies.urlOpener.open(item.url)
            }
        }
    }

    private var appInfoItemsSection: some View {
        hSection(appInfoItems, id: \.title) { item in
            hRow {
                HStack {
                    hText(item.title)
                        .foregroundColor(hTextColor.Opaque.primary)
                    Spacer()
                    hText(item.subtitle, style: .body1)
                        .minimumScaleFactor(0.2)
                        .lineLimit(1)
                        .foregroundColor(hTextColor.Opaque.secondary)
                }
            }
            .withEmptyAccessory
            .onTap {
                UIPasteboard.general.string = item.subtitle
                showToaster()
            }
            .hRowContentAlignment(.center)
        }
        .withHeader(
            title: "",
            extraView: (
                view: hPill(
                    text: L10n.profileAppInfo,
                    color: .blue,
                    colorLevel: .one,
                    withBorder: false
                )
                .asAnyView, alignment: .top
            )
        )
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

extension InformationScreen {
    fileprivate var legalItems: [LegalItem] {
        let baseURL = Environment.current.webBaseURL
        let locale = Localization.Locale.currentLocale.value
        let webPath = locale.webPath
        return [
            LegalItem(
                title: L10n.legalPrivacyPolicy,
                url: baseURL.appendingPathComponent("\(webPath)/hedvig/\(locale.privacyPolicyPath)")
            ),
            LegalItem(
                title: L10n.legalInformation,
                url: baseURL.appendingPathComponent("\(webPath)/hedvig/legal")
            ),
            LegalItem(
                title: L10n.legalA11Y,
                url: baseURL.appendingPathComponent("\(webPath)/\(locale.accessibilityPath)")
            ),
        ]
    }

    fileprivate var appInfoItems: [AppInfoItem] {
        let profileStore: ProfileStore = globalPresentableStoreContainer.get()
        var appInfoItems = [AppInfoItem]()
        if let memberId = profileStore.state.memberDetails?.id {
            appInfoItems.append(AppInfoItem(title: L10n.profileAboutAppMemberId, subtitle: memberId))
        }
        let appVersion = Bundle.main.appVersion
        appInfoItems.append(.init(title: L10n.profileAboutAppVersion, subtitle: appVersion))
        if let deviceId = vm.deviceId {
            appInfoItems.append(.init(title: L10n.AppInfo.deviceIdLabel, subtitle: deviceId))
        }
        return appInfoItems
    }
}

@MainActor
class InformationViewModel: ObservableObject {
    @Published var deviceId: String?

    init() {
        Task {
            let deviceId = await ApolloClient.getDeviceIdentifier()
            self.deviceId = deviceId
        }
    }
}

private struct LegalItem {
    let title: String
    let url: URL
}

private struct AppInfoItem {
    let title: String
    let subtitle: String
}

extension Localization.Locale {
    fileprivate var privacyPolicyPath: String {
        switch self {
        case .sv_SE: return "personuppgifter"
        case .en_SE: return "privacy-policy"
        }
    }

    fileprivate var accessibilityPath: String {
        switch self {
        case .sv_SE: return "hjalp/tillganglighet"
        case .en_SE: return "help/accessibility"
        }
    }
}

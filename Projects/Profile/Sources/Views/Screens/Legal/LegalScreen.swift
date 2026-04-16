import Environment
import SwiftUI
import hCore
import hCoreUI

struct LegalScreen: View {
    private var items: [LegalItem] {
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

    var body: some View {
        hForm {
            hSection(items, id: \.title) { item in
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
            .sectionContainerStyle(.transparent)
            .padding(.top, .padding8)
        }
        .hWithoutHorizontalPadding([.row, .divider])
    }
}

private struct LegalItem {
    let title: String
    let url: URL
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

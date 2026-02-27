import SwiftUI
import hCore
import hCoreUI

struct AddonViewRow: View {
    let title: String
    let subtitle: String
    let actionTitle: String
    let buttonType: hButtonConfigurationType
    let activationDate: String?
    let terminationDate: String?
    let action: (() -> Void)

    init(
        title: String,
        subtitle: String,
        actionTitle: String,
        buttonType: hButtonConfigurationType,
        activationDate: String? = nil,
        terminationDate: String? = nil,
        action: @escaping (() -> Void),
    ) {
        self.title = title
        self.subtitle = subtitle
        self.actionTitle = actionTitle
        self.buttonType = buttonType
        self.activationDate = activationDate
        self.terminationDate = terminationDate
        self.action = action
    }

    var displayDescription: String {
        if let activationDate { return L10n.contractOverviewAddonActivatesDate(activationDate) }
        if let terminationDate { return L10n.contractOverviewAddonEndsDate(terminationDate) }
        return subtitle
    }

    var body: some View {
        hRow {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    hText(title)
                        .accessibilityLabel(L10n.insuranceAddonSubheading + " " + title)
                    hText(displayDescription, style: .label)
                        .foregroundColor(hTextColor.Translucent.secondary)
                }
                Spacer(minLength: 0)
                hButton(.small, buttonType, content: .init(title: actionTitle), action)
                    .hFieldSize(.small)
            }
        }
        .containerShape(.rect)
        .onTapGesture(perform: action)
        .accessibilityElement(children: .combine)
    }
}

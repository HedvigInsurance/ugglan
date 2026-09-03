import SwiftUI
import hCoreUI

public struct ContractOwnerField: View {
    let enabled: Bool?
    let fullName: String
    let SSN: String

    public init(
        enabled: Bool? = false,
        fullName: String,
        SSN: String
    ) {
        self.enabled = enabled
        self.fullName = fullName
        self.SSN = SSN.displayFormatSSN ?? ""
    }

    public init(
        enabled: Bool? = false,
        config: StakeholdersConfig
    ) {
        self.enabled = enabled
        fullName = config.holderFullName
        SSN = config.holderSSN?.displayFormatSSN ?? ""
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                hText(fullName)
                    .foregroundColor(getTitleColor)
                Spacer()
                hCoreUIAssets.lock.view
                    .foregroundColor(hTextColor.Opaque.tertiary)
            }
            hText(SSN, style: .label)
                .foregroundColor(getSubTitleColor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }

    @hColorBuilder
    var getTitleColor: some hColor {
        if enabled ?? false {
            hTextColor.Opaque.primary
        } else {
            hTextColor.Opaque.tertiary
        }
    }

    @hColorBuilder
    var getSubTitleColor: some hColor {
        if enabled ?? false {
            hTextColor.Opaque.secondary
        } else {
            hTextColor.Opaque.tertiary
        }
    }
}

import SwiftUI
import hCoreUI

public struct ContractOwnerField: View {
    let enabled: Bool?
    let hasContentBelow: Bool
    let fullName: String
    let SSN: String
    let multiplier = HFontTextStyle.body1.multiplier

    public init(
        enabled: Bool? = false,
        hasContentBelow: Bool,
        fullName: String,
        SSN: String
    ) {
        self.enabled = enabled
        self.hasContentBelow = hasContentBelow
        self.fullName = fullName
        self.SSN = SSN.displayFormatSSN ?? ""
    }

    public init(
        enabled: Bool? = false,
        hasContentBelow: Bool,
        config: InsuredPeopleConfig
    ) {
        self.enabled = enabled
        self.hasContentBelow = hasContentBelow
        self.fullName = config.holderFullName
        self.SSN = config.holderSSN?.displayFormatSSN ?? ""
    }

    public var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: multiplier != 1 ? .padding24 * multiplier : 0) {
                HStack {
                    hText(fullName)
                        .foregroundColor(getTitleColor)
                    Spacer()
                    Image(uiImage: hCoreUIAssets.lock.image)
                        .foregroundColor(hTextColor.Opaque.tertiary)
                }
                hText(SSN, style: .label)
                    .foregroundColor(getSubTitleColor)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            if hasContentBelow {
                Divider()
                    .padding(.top, multiplier != 1 ? .padding8 * multiplier : 0)
            }
        }
        .padding(.bottom, hasContentBelow ? 0 : 16)
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

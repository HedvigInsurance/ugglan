import SwiftUI
import hCore
import hCoreUI

public struct ContractOwnerField: View {
    let enabled: Bool?
    let hasContentBelow: Bool
    let fullName: String
    let SSN: String
    @PresentableStore var store: EditCoInsuredStore

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
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    hText(fullName)
                        .foregroundColor(getTitleColor)
                    Spacer()
                    Image(uiImage: hCoreUIAssets.lockSmall.image)
                        .foregroundColor(hTextColor.tertiary)
                }
                hText(SSN, style: .footnote)
                    .foregroundColor(getSubTitleColor)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            if hasContentBelow {
                Divider()
            }
        }
        .padding(.bottom, hasContentBelow ? 0 : 16)
    }

    @hColorBuilder
    var getTitleColor: some hColor {
        if enabled ?? false {
            hTextColor.primary
        } else {
            hTextColor.tertiary
        }
    }

    @hColorBuilder
    var getSubTitleColor: some hColor {
        if enabled ?? false {
            hTextColor.secondary
        } else {
            hTextColor.tertiary
        }
    }
}

public struct CoInsuredField<Content: View>: View {
    let coInsured: CoInsuredModel?
    let accessoryView: Content
    let includeStatusPill: StatusPillType?
    let date: String
    let title: String?
    let subTitle: String?

    public init(
        coInsured: CoInsuredModel? = nil,
        accessoryView: Content,
        includeStatusPill: StatusPillType? = nil,
        date: String? = nil,
        title: String? = nil,
        subTitle: String? = nil
    ) {
        self.coInsured = coInsured
        self.accessoryView = accessoryView

        var statusPill: StatusPillType? {
            if includeStatusPill == nil {
                if coInsured?.activatesOn != nil {
                    return .added
                } else if coInsured?.terminatesOn != nil {
                    return .deleted
                }
            }
            return nil
        }

        self.includeStatusPill = includeStatusPill ?? statusPill

        self.date = date ?? coInsured?.activatesOn ?? coInsured?.terminatesOn ?? ""
        self.title = title
        self.subTitle = subTitle
    }

    public var body: some View {
        let displayTitle = (coInsured?.fullName ?? title) ?? ""
        let displaySubTitle =
            coInsured?.formattedSSN?.displayFormatSSN ?? coInsured?.birthDate?.birtDateDisplayFormat ?? subTitle ?? ""

        VStack(spacing: 4) {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    hText(displayTitle)
                        .fixedSize()
                    Spacer()
                    accessoryView
                }
                hText(displaySubTitle, style: .standardSmall)
                    .foregroundColor(hTextColor.secondary)
                    .fixedSize()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            if let includeStatusPill, let coInsured {
                statusPill
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    @ViewBuilder
    var statusPill: some View {
        VStack {
            hText(
                includeStatusPill?
                    .text(date: date.localDateToDate?.displayDateDDMMMYYYYFormat ?? "")
                    ?? "",
                style: .standardSmall
            )
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 10)
        .foregroundColor(includeStatusPill?.textColor)
        .background(includeStatusPill?.backgroundColor)
        .cornerRadius(8)
    }
}

public enum StatusPillType {
    case added
    case deleted

    func text(date: String) -> String {
        switch self {
        case .added:
            return L10n.contractAddCoinsuredActiveFrom(date)
        case .deleted:
            return L10n.contractAddCoinsuredActiveUntil(date)
        }
    }

    @hColorBuilder
    var textColor: some hColor {
        switch self {
        case .added:
            hSignalColor.amberText
        case .deleted:
            hSignalColor.redText
        }
    }

    @hColorBuilder
    var backgroundColor: some hColor {
        switch self {
        case .added:
            hSignalColor.amberFill
        case .deleted:
            hSignalColor.redFill
        }
    }
}

struct ContractOwnerField_Previews: PreviewProvider {
    static var previews: some View {
        ContractOwnerField(hasContentBelow: true, fullName: "", SSN: "")
    }
}

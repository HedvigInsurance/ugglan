import SwiftUI
import hCoreUI

@MainActor
public struct CoInsuredField<Content: View>: View {
    let coInsured: CoInsuredModel?
    let accessoryView: Content
    let includeStatusPill: StatusPillType?
    let date: String
    let title: String?
    let subTitle: String?
    let multiplier = HFontTextStyle.body1.multiplier

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
            VStack(alignment: .leading, spacing: multiplier != 1 ? .padding8 * multiplier : 0) {
                HStack {
                    hText(displayTitle)
                        .fixedSize(horizontal: multiplier != 1 ? false : true, vertical: false)
                    Spacer()
                    accessoryView
                }
                hText(displaySubTitle, style: .label)
                    .foregroundColor(hTextColor.Opaque.secondary)
                    .fixedSize(horizontal: multiplier != 1 ? false : true, vertical: false)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            statusPill

        }
    }

    @ViewBuilder
    var statusPill: some View {
        if let includeStatusPill {
            VStack {
                hText(
                    includeStatusPill
                        .text(date: (date.localDateToDate?.displayDateDDMMMYYYYFormat ?? "")),
                    style: .label
                )
            }
            .padding(.vertical, .padding4)
            .padding(.horizontal, .padding10)
            .foregroundColor(includeStatusPill.textColor)
            .background(includeStatusPill.backgroundColor)
            .cornerRadius(8)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

@MainActor
extension StatusPillType {
    @hColorBuilder
    var textColor: some hColor {
        switch self {
        case .added:
            hSignalColor.Amber.text
        case .deleted:
            hSignalColor.Red.text
        }
    }

    @hColorBuilder
    var backgroundColor: some hColor {
        switch self {
        case .added:
            hSignalColor.Amber.fill
        case .deleted:
            hSignalColor.Red.fill
        }
    }
}

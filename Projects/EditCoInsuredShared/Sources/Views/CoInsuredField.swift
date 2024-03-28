import SwiftUI
import hCoreUI

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
            if let includeStatusPill {
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
                    .text(date: (date.localDateToDate?.displayDateDDMMMYYYYFormat ?? ""))
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

extension StatusPillType {
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

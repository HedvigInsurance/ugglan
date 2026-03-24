import SwiftUI
import hCore
import hCoreUI

@MainActor
public struct StakeholderField<Content: View>: View {
    let stakeholder: Stakeholder?
    let accessoryView: Content
    let statusPill: StatusPillType?
    let date: String
    let subTitle: String?
    let stakeholderType: StakeholderType

    public init(
        stakeholder: Stakeholder? = nil,
        accessoryView: Content,
        statusPill: StatusPillType? = nil,
        date: String? = nil,
        stakeholderType: StakeholderType
    ) {
        self.stakeholder = stakeholder
        self.accessoryView = accessoryView
        self.statusPill =
            statusPill
            ?? {
                guard stakeholder?.hasMissingData == false else { return nil }
                if stakeholder?.activatesOn != nil {
                    return .added
                } else if stakeholder?.terminatesOn != nil {
                    return .deleted
                }
                return nil
            }()
        self.date = date ?? stakeholder?.activatesOn ?? stakeholder?.terminatesOn ?? ""
        subTitle = stakeholder?.hasMissingData ?? true ? L10n.contractNoInformation : nil
        self.stakeholderType = stakeholderType
    }

    public var body: some View {
        let displayTitle = stakeholder?.fullName ?? stakeholderType.defaultFieldLabel
        let displaySubTitle =
            stakeholder?.formattedSSN?.displayFormatSSN ?? stakeholder?.birthDate?.birtDateDisplayFormat ?? subTitle
            ?? ""

        VStack(spacing: .padding4) {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    hText(displayTitle)
                        .fixedSize()
                    Spacer()
                    accessoryView
                }
                hText(displaySubTitle, style: .label)
                    .foregroundColor(hTextColor.Opaque.secondary)
                    .fixedSize()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            statusPillView
        }
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    var statusPillView: some View {
        if let statusPill {
            VStack {
                hText(
                    statusPill
                        .text(date: (date.localDateToDate?.displayDateDDMMMYYYYFormat ?? "")),
                    style: .label
                )
            }
            .padding(.vertical, .padding4)
            .padding(.horizontal, .padding10)
            .foregroundColor(statusPill.textColor)
            .background(statusPill.backgroundColor)
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

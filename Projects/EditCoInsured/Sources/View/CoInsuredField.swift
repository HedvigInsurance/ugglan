import SwiftUI
import hCore
import hCoreUI

@MainActor
public struct CoInsuredField<Content: View>: View {
    let coInsured: CoInsuredModel?
    let accessoryView: Content
    let statusPill: StatusPillType?
    let date: String
    let subTitle: String?

    public init(
        coInsured: CoInsuredModel? = nil,
        accessoryView: Content,
        statusPill: StatusPillType? = nil,
        date: String? = nil,
    ) {
        self.coInsured = coInsured
        self.accessoryView = accessoryView
        self.statusPill =
            statusPill
            ?? {
                guard coInsured?.hasMissingData == false else { return nil }
                if coInsured?.activatesOn != nil {
                    return .added
                } else if coInsured?.terminatesOn != nil {
                    return .deleted
                }
                return nil
            }()
        self.date = date ?? coInsured?.activatesOn ?? coInsured?.terminatesOn ?? ""
        subTitle = coInsured?.hasMissingData ?? true ? L10n.contractNoInformation : nil
    }

    public var body: some View {
        let displayTitle = coInsured?.fullName ?? L10n.contractCoinsured
        let displaySubTitle =
            coInsured?.formattedSSN?.displayFormatSSN ?? coInsured?.birthDate?.birtDateDisplayFormat ?? subTitle ?? ""

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

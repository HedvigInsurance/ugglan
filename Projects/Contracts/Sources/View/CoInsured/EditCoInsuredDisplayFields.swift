import SwiftUI
import hCore
import hCoreUI

struct ContractOwnerField: View {
    let contractId: String
    let enabled: Bool?
    let hasContentBelow: Bool

    init(
        contractId: String,
        enabled: Bool? = false,
        hasContentBelow: Bool
    ) {
        self.contractId = contractId
        self.enabled = enabled
        self.hasContentBelow = hasContentBelow
    }

    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 0) {
                PresentableStoreLens(
                    ContractStore.self,
                    getter: { state in
                        state.contractForId(contractId)
                    }
                ) { contract in
                    if let contract = contract {
                        HStack {
                            hText(contract.fullName)
                                .foregroundColor(getTitleColor)
                            Spacer()
                            Image(uiImage: hCoreUIAssets.lockSmall.image)
                                .foregroundColor(hTextColor.tertiary)
                        }
                        hText(contract.ssn ?? "", style: .footnote)
                            .foregroundColor(getSubTitleColor)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            if hasContentBelow {
                Divider()
            }
        }
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

struct CoInsuredField<Content: View>: View {
    let coInsured: CoInsuredModel?
    let accessoryView: Content
    let includeStatusPill: StatusPillType?
    let date: String?
    let title: String?
    let subTitle: String?

    init(
        coInsured: CoInsuredModel? = nil,
        accessoryView: Content,
        includeStatusPill: StatusPillType? = nil,
        date: String? = nil,
        title: String? = nil,
        subTitle: String? = nil
    ) {
        self.coInsured = coInsured
        self.accessoryView = accessoryView
        self.includeStatusPill = includeStatusPill
        self.date = date
        self.title = title
        self.subTitle = subTitle
    }

    var body: some View {
        let displayTitle = (coInsured?.fullName ?? title) ?? ""
        let displaySubTitle = coInsured?.displayFormatSSN ?? coInsured?.birthDate?.birtDateDisplayFormat ?? subTitle ?? ""

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
                    .text(date: date?.localDateToDate?.displayDateDDMMMYYYYFormat ?? "")
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

enum StatusPillType {
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
        ContractOwnerField(contractId: "", hasContentBelow: true)
    }
}

import Presentation
import SwiftUI
import hCore
import hCoreUI

struct ContractOwnerField: View {
    let coInsured: [CoInsuredModel]
    let contractId: String

    init(
        coInsured: [CoInsuredModel],
        contractId: String
    ) {
        self.coInsured = coInsured
        self.contractId = contractId
    }

    var body: some View {
        hSection {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    PresentableStoreLens(
                        ContractStore.self,
                        getter: { state in
                            state.contractForId(contractId)
                        }
                    ) { contract in
                        hText(contract?.fullName ?? "")
                            .fixedSize()
                        hText(contract?.ssn ?? "", style: .standardSmall)
                    }
                }
                .foregroundColor(hTextColor.tertiary)
                Spacer()
                HStack(alignment: .top) {
                    Image(uiImage: hCoreUIAssets.lockSmall.image)
                        .foregroundColor(hTextColor.tertiary)
                        .frame(maxWidth: .infinity, alignment: .topTrailing)
                }
            }
            .padding(.vertical, 16)
            Divider()
        }
        .sectionContainerStyle(.transparent)
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
        VStack(spacing: 4) {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    if let coInsured = coInsured, let fullName = coInsured.fullName {
                        hText(fullName)
                            .fixedSize()
                        hText(coInsured.SSN ?? coInsured.birthDate ?? "", style: .standardSmall)
                            .foregroundColor(hTextColor.secondary)
                            .fixedSize()
                    } else {
                        hText(title ?? "")
                            .fixedSize()
                        hText(subTitle ?? "", style: .standardSmall)
                            .foregroundColor(hTextColor.secondary)
                            .fixedSize()
                    }
                }
                Spacer()
                HStack {
                    Spacer()
                    accessoryView
                }
            }
        }
        .padding(.vertical, (includeStatusPill != nil) ? 0 : 16)
        .padding(.top, (includeStatusPill != nil) ? 16 : 0)
        if let includeStatusPill, let coInsured {
            statusPill
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 16)
                .padding(.top, 5)
        }
        Divider()
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
        ContractOwnerField(coInsured: [], contractId: "")
    }
}

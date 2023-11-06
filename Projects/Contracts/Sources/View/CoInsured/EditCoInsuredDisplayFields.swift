import SwiftUI
import hCore
import hCoreUI

struct ContractOwnerField: View {
    let coInsured: [CoInsuredModel]

    init(
        coInsured: [CoInsuredModel]
    ) {
        self.coInsured = coInsured
    }

    var body: some View {
        hSection {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    /* TODO: CHANGE WHEN REAL DATA */
                    hText("Julia Andersson")
                        .fixedSize()
                    hText("19900101-1111")
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
    let includeStatusPill: Bool?
    let title: String?
    let subTitle: String?

    init(
        coInsured: CoInsuredModel? = nil,
        accessoryView: Content,
        includeStatusPill: Bool? = false,
        title: String? = nil,
        subTitle: String? = nil
    ) {
        self.coInsured = coInsured
        self.accessoryView = accessoryView
        self.includeStatusPill = includeStatusPill
        self.title = title
        self.subTitle = subTitle
    }

    var body: some View {
        VStack(spacing: 4) {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    if let coInsured {
                        hText(coInsured.name ?? "")
                            .fixedSize()
                        hText(coInsured.SSN ?? "")
                            .foregroundColor(hTextColor.secondary)
                            .fixedSize()
                    } else {
                        hText(title ?? "")
                        hText(subTitle ?? "")
                            .foregroundColor(hTextColor.secondary)
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
        .padding(.vertical, (includeStatusPill ?? false) ? 0 : 16)
        .padding(.top, (includeStatusPill ?? false) ? 16 : 0)
        if includeStatusPill ?? false, let coInsured {
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
                //TODO: Set proper data
                L10n.contractAddCoinsuredActiveFrom("2023-11-16".localDateToDate?.displayDateDDMMMYYYYFormat ?? ""),
                style: .standardSmall
            )
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 10)
        .foregroundColor(hSignalColor.amberText)
        .background(hSignalColor.amberFill)
        .cornerRadius(8)
    }
}

struct ContractOwnerField_Previews: PreviewProvider {
    static var previews: some View {
        ContractOwnerField(coInsured: [])
    }
}

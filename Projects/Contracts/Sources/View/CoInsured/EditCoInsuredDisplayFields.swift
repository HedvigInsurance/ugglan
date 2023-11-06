import SwiftUI
import hCore
import hCoreUI
import Presentation

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
                        /* TODO: CHANGE WHEN REAL DATA */
                        hText("19900101-1111")
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
    let includeStatusPill: Bool?
    let title: String?
    let subTitle: String?
    @ObservedObject var intentVm: IntentViewModel

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
        let store: ContractStore = globalPresentableStoreContainer.get()
        intentVm = store.intentViewModel
    }

    var body: some View {
        VStack(spacing: 4) {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    if let coInsured {
                        hText(coInsured.fullName ?? "")
                            .fixedSize()
                        hText(coInsured.SSN ?? coInsured.birthDate ?? "")
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
                L10n.contractAddCoinsuredActiveFrom(intentVm.activationDate.localDateToDate?.displayDateDDMMMYYYYFormat ?? ""),
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
        ContractOwnerField(coInsured: [], contractId: "")
    }
}

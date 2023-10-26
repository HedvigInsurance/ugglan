import SwiftUI
import hCore
import hCoreUI

struct ContractOwnerField: View {
    let coInsured: [CoInsuredModel]
    
    init(
        coInsured: [CoInsuredModel]
    ){
        self.coInsured = coInsured
    }
    
    var body: some View {
        hSection {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    hText("Julia Andersson")
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
            hRowDivider()
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
    ){
        self.coInsured = coInsured
        self.accessoryView = accessoryView
        self.includeStatusPill = includeStatusPill
        self.title = title
        self.subTitle = subTitle
    }
    
    var body: some View {
        VStack(spacing: 4) {
            HStack {
                VStack(alignment: .leading) {
                    if let coInsured {
                        hText(coInsured.name)
                        hText(coInsured.SSN)
                            .foregroundColor(hTextColor.secondary)
                            .fixedSize()
                    } else {
                        hText(title ?? "")
                        hText(subTitle ?? "")
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
        .padding(.vertical, (includeStatusPill ?? false) ? 0 : 16 )
        .padding(.top, (includeStatusPill ?? false) ? 16 : 0 )
        if includeStatusPill ?? false, let coInsured {
            statusPill(coInsured: coInsured)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 16)
        }
        hRowDivider()
    }
    
    @ViewBuilder
    func statusPill(coInsured: CoInsuredModel) -> some View {
        VStack {
            switch coInsured.type {
            case .added:
                hText(L10n.contractAddCoinsuredActiveFrom("16 nov 2023"), style: .standardSmall)
            case .deleted:
                hText(L10n.contractAddCoinsuredActiveUntil("16 nov 2023"), style: .standardSmall)
            case .none:
                EmptyView()
            }
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 10)
        .foregroundColor(pillTextdColor(coInsured: coInsured))
        .background(pillBackgroundColor(coInsured: coInsured))
        .cornerRadius(8)
    }
    
    @hColorBuilder
    func pillBackgroundColor(coInsured: CoInsuredModel) -> some hColor {
        switch coInsured.type {
        case .added:
            hSignalColor.amberFill
        case .deleted:
            hSignalColor.redFill
        case .none:
            hBackgroundColor.clear
        }
    }
    
    @hColorBuilder
    func pillTextdColor(coInsured: CoInsuredModel) -> some hColor {
        switch coInsured.type {
        case .added:
            hSignalColor.amberText
        case .deleted:
            hSignalColor.redText
        case .none:
            hBackgroundColor.clear
        }
    }
}

struct ContractOwnerField_Previews: PreviewProvider {
    static var previews: some View {
        ContractOwnerField(coInsured: [])
    }
}

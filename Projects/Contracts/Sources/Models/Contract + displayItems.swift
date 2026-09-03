import EditStakeholders
import hCore

extension Contract {
    func getDisplayItems() -> [ContractInformationDisplayItem] {
        var items = currentAgreement?.getDisplayItems() ?? []
        guard supportsCoInsured || supportsCoOwners || typeOfContract.isPaymentProtection else { return items }

        let coInsuredValue =
            coInsured.isEmpty ? L10n.changeAddressOnlyYou : L10n.changeAddressYouPlus(coInsured.count)
        items.append(
            .init(
                id: "supportedPpl",
                type: .regular(title: L10n.coinsuredEditTitle, value: coInsuredValue, subtitle: nil)
            )
        )
        // A stakeholder item without a person renders the contract owner.
        items.append(.init(id: "owner", type: .stakeholder(item: nil)))
        items.append(contentsOf: stakeholderItems.map { .init(id: $0.id, type: .stakeholder(item: $0)) })
        return items
    }

    private var stakeholderItems: [StakeholderItem] {
        coInsured.map { $0.asStakeholderItem(type: .coInsured) }
            + coOwners.map { $0.asStakeholderItem(type: .coOwner) }
    }
}

extension Agreement {
    func getDisplayItems() -> [ContractInformationDisplayItem] {
        let items = displayItems.map { displayItem in
            ContractInformationDisplayItem(
                id: displayItem.id,
                type: .regular(
                    title: displayItem.displayTitle,
                    value: displayItem.displayValue,
                    subtitle: displayItem.displaySubtitle
                )
            )
        }
        guard let itemCost else { return items }
        return items + [.init(id: "itemCost", type: .itemCost(cost: itemCost))]
    }
}

struct ContractInformationDisplayItem: Identifiable {
    let id: String
    let type: ItemType

    enum ItemType {
        case stakeholder(item: StakeholderItem?)
        case itemCost(cost: ItemCost)
        case regular(title: String, value: String, subtitle: String?)
    }
}

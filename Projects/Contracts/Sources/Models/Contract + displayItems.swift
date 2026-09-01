import EditStakeholders
import hCore

extension Contract {
    func getDisplayItems() -> [ContractInformationDisplayItem] {
        var items = [ContractInformationDisplayItem]()
        if let displayItems = currentAgreement?.getDisplayItems() {
            items.append(contentsOf: displayItems)
        }
        if supportsCoInsured || supportsCoOwners || typeOfContract.isPaymentProtection {
            let supportedPplValue =
                switch coInsured.count {
                case 0: L10n.changeAddressOnlyYou
                default: L10n.changeAddressYouPlus(coInsured.count)
                }
            items.append(
                .init(
                    id: "supportedPpl",
                    type: .regular(title: L10n.coinsuredEditTitle, value: supportedPplValue, subtitle: nil)
                )
            )

            items.append(
                .init(
                    id: "owner",
                    type: .stakeholderItem(
                        item: nil
                    )
                )
            )
            for stakeholderItem in stakeholderItems() {
                items.append(.init(id: stakeholderItem.id, type: .stakeholderItem(item: stakeholderItem)))
            }
        }
        return items
    }

    fileprivate func stakeholderItems() -> [StakeholderItem] {
        coInsured.map { $0.asStakeholderItem(type: .coInsured) }
            + coOwners.map { $0.asStakeholderItem(type: .coOwner) }
    }
}

extension Agreement {
    func getDisplayItems() -> [ContractInformationDisplayItem] {
        let displayItems = displayItems.map { displayItem in
            ContractInformationDisplayItem(
                id: displayItem.id,
                type: .regular(
                    title: displayItem.displayTitle,
                    value: displayItem.displayValue,
                    subtitle: displayItem.displaySubtitle
                )
            )
        }

        let itemCostDisplayItem = itemCost.map({ itemCost in
            ContractInformationDisplayItem(id: "itemCost", type: .itemCost(cost: itemCost))
        })
        if let itemCostDisplayItem {
            return displayItems + [itemCostDisplayItem]
        }
        return displayItems
    }
}

struct ContractInformationDisplayItem: Identifiable {
    let id: String
    let type: ContractInformationDisplayItemType

    enum ContractInformationDisplayItemType {
        case stakeholderItem(item: StakeholderItem?)
        case itemCost(cost: ItemCost)
        case regular(title: String, value: String, subtitle: String?)
    }
}

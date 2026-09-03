import EditStakeholders
import SwiftUI
import hCore
import hCoreUI

/// Renders a single row of a contract's or an agreement's display items.
///
/// Screens that only show agreement items use `init(item:)`; screens that also
/// list people pass a builder for the stakeholder rows.
struct ContractDisplayItemRow<StakeholderRow: View>: View {
    private let item: ContractInformationDisplayItem
    private let stakeholderRow: (StakeholderItem?) -> StakeholderRow

    init(
        item: ContractInformationDisplayItem,
        @ViewBuilder stakeholderRow: @escaping (StakeholderItem?) -> StakeholderRow
    ) {
        self.item = item
        self.stakeholderRow = stakeholderRow
    }

    @ViewBuilder
    var body: some View {
        switch item.type {
        case let .regular(title, value, subtitle):
            hRow {
                VStack(alignment: .leading, spacing: 0) {
                    hText(title)
                    if let subtitle {
                        hText(subtitle, style: .label)
                            .foregroundColor(hTextColor.Translucent.secondary)
                    }
                }
            }
            .withCustomAccessory {
                Group {
                    Spacer()
                    if let date = value.localDateToDate?.displayDateDDMMMYYYYFormat {
                        hText(date)
                    } else {
                        ZStack {
                            hText(value)
                            hText(" ")
                        }
                    }
                }
                .foregroundColor(hTextColor.Opaque.secondary)
            }
            .accessibilityElement(children: .combine)
        case let .itemCost(cost):
            hRow {
                ItemCostView(itemCost: cost)
            }
        case let .stakeholder(stakeholderItem):
            stakeholderRow(stakeholderItem)
        }
    }
}

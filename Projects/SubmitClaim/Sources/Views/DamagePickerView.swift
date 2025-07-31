import SwiftUI
import hCore
import hCoreUI

struct DamagePickerView: View {
    @ObservedObject var claimsNavigationVm: SubmitClaimNavigationViewModel

    var body: some View {
        ItemPickerScreen<ClaimFlowItemProblemOptionModel>(
            config: .init(
                items: claimsNavigationVm.singleItemModel?.availableItemProblems
                    .compactMap { (object: $0, displayName: .init(title: $0.displayName)) } ?? [],
                preSelectedItems: {
                    if let singleItemStep = claimsNavigationVm.singleItemModel {
                        let preselected = singleItemStep.availableItemProblems
                            .filter { model in
                                singleItemStep.selectedItemProblems?
                                    .contains(where: { item in
                                        model.itemProblemId == item
                                    }) ?? false
                            }
                        return preselected
                    }
                    return []
                },
                onSelected: { selectedDamages in
                    var damages: [String] = []

                    for damage in selectedDamages {
                        if let object = damage.0 {
                            damages.append(object.itemProblemId)
                        }
                    }
                    claimsNavigationVm.isDamagePickerPresented = false
                    claimsNavigationVm.singleItemModel?.selectedItemProblems = damages
                },
                onCancel: {
                    claimsNavigationVm.router.dismiss()
                }
            )
        )
        .hFormContentPosition(.compact)
        .configureTitle(L10n.Claims.Item.Screen.Damage.button)
    }
}

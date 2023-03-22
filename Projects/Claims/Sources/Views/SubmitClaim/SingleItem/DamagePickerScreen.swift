import SwiftUI
import hCore
import hCoreUI

public struct DamamagePickerScreen: View {
    @PresentableStore var store: ClaimsStore
    @State var selectedDamages: [Damage] = []

    public init() {
    }

    public var body: some View {

        PresentableStoreLens(
            ClaimsStore.self,
            getter: { state in
                state.newClaim
            }
        ) { claim in

            let damages = claim.listOfDamage

            hForm {
                hSection {
                    ForEach(damages ?? [], id: \.self) { damage in

                        MultipleSelectionRow(
                            selectedDamage: damage,
                            selectedDamages: selectedDamages,
                            isSelected: self.selectedDamages.contains(damage)
                        ) {
                            if self.selectedDamages.contains(damage) {
                                self.selectedDamages.removeAll(where: { $0 == damage })
                            } else {
                                self.selectedDamages.append(damage)
                            }
                        }
                    }
                }
            }
            //            .hFormAttachToBottom {
            //                hButton.LargeButtonFilled  {
            //                    store.send(.submitDamage(damage: selectedDamages))
            //                } content: {
            //                    hText(L10n.generalContinueButton)
            //                }
            //                .padding([.leading, .trailing], 16)
            //            }
        }
    }
}

struct MultipleSelectionRow: View {
    @PresentableStore var store: ClaimsStore
    let selectedDamage: Damage
    @State var selectedDamages: [Damage]
    var isSelected: Bool
    var action: () -> Void

    var body: some View {

        hButton.SmallButtonText(action: self.action) {
            HStack {
                hRow {
                    hText(selectedDamage.displayName, style: .body)
                        .foregroundColor(hLabelColor.primary)

                    if self.isSelected {
                        Spacer()
                        Image(systemName: "checkmark") /* TODO: CHANGE IMAGE */

                        let newDamage = Damage(
                            displayName: selectedDamage.displayName,
                            itemProblemId: selectedDamage.itemProblemId
                        )

                        if let _ = !selectedDamages.contains(newDamage) {
                            let _ = selectedDamages.append(newDamage)
                        } else {
                            let index = selectedDamages.firstIndex(of: newDamage)

                            if let index = index {
                                let _ = selectedDamages.remove(at: index)
                            }
                        }

                        PresentableStoreLens(
                            ClaimsStore.self,
                            getter: { state in
                                state.newClaim
                            },
                            setter: { value in
                                .setSingleItemDamage(damages: value.chosenDamages ?? selectedDamages)
                            }
                        ) { value, setter in

                            //                                .setSingleItemDamage(damages: selectedDamages)
                            //                            let _ = print("damages: ", claim.chosenDamages)
                            //                            value(.setSingleItemDamage(damages: selectedDamages))

                        }
                    }
                }
            }
        }
    }
}

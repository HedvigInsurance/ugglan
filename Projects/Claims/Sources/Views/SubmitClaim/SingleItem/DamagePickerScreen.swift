import SwiftUI
import hCore
import hCoreUI

//import Combine

public struct DamamagePickerScreen: View {
    @PresentableStore var store: ClaimsStore
    @State var selectedDamages: [Damage] = []

    public init() {}

    public var body: some View {
        hForm {
            hSection {

                PresentableStoreLens(
                    ClaimsStore.self,
                    getter: { state in
                        state.newClaim
                    }
                ) { claim in

                    let damage = claim.listOfDamage

                    ForEach(damage ?? [], id: \.self) { element in
                        hRow {
                            hText(element.displayName, style: .body)
                                .foregroundColor(hLabelColor.primary)
                        }
                        .withSelectedAccessory(selectedDamages.contains(element))
                        .onTap {
                            let newDamage = Damage(
                                displayName: element.displayName,
                                itemProblemId: element.itemProblemId
                            )

                            withAnimation {
                                if !selectedDamages.contains(newDamage) {
                                    selectedDamages.append(newDamage)
                                } else {
                                    let index = selectedDamages.firstIndex(of: newDamage)

                                    if let index = index {
                                        selectedDamages.remove(at: index)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .hFormAttachToBottom {
            hButton.LargeButtonFilled {
                store.send(.submitDamage(damage: selectedDamages))
            } content: {
                hText(L10n.generalContinueButton)
            }
            .padding([.leading, .trailing], 16)
        }
        .onAppear {
            self.selectedDamages = store.state.newClaim.chosenDamages ?? []
        }
    }
}

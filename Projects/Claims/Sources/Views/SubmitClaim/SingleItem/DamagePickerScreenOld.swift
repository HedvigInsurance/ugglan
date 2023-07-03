import SwiftUI
import hCore
import hCoreUI

public struct DamamagePickerScreenOld: View {
    @PresentableStore var store: SubmitClaimStore
    @State var selectedDamages: [String] = []

    public init() {}
    public var body: some View {
        hForm {
            hSection {

                PresentableStoreLens(
                    SubmitClaimStore.self,
                    getter: { state in
                        state.singleItemStep
                    }
                ) { claim in

                    let damage = claim?.availableItemProblems ?? []

                    ForEach(damage, id: \.itemProblemId) { element in
                        hRow {
                            hText(element.displayName, style: .body)
                                .foregroundColor(hLabelColor.primary)
                        }
                        .withSelectedAccessory(selectedDamages.contains(element.itemProblemId))
                        .onTap {
                            let itemProblemId = element.itemProblemId
                            withAnimation {
                                if !selectedDamages.contains(itemProblemId) {
                                    selectedDamages.append(itemProblemId)
                                } else {
                                    if let index = selectedDamages.firstIndex(of: itemProblemId) {
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
                store.send(
                    .submitDamage(
                        damage: selectedDamages
                    )
                )
            } content: {
                hText(L10n.generalContinueButton)
            }
            .padding([.leading, .trailing], 16)
        }
        .onAppear {
            self.selectedDamages = store.state.singleItemStep?.selectedItemProblems ?? []
        }
    }
}

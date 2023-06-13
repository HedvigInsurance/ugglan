import SwiftUI
import hCore
import hCoreUI

public struct DamamagePickerScreen: View {
    @PresentableStore var store: SubmitClaimStore
    @State var selectedDamages: [String] = []

    public init() {}
    public var body: some View {
        hForm {
            PresentableStoreLens(
                SubmitClaimStore.self,
                getter: { state in
                    state.singleItemStep
                }
            ) { claim in

                let damage = claim?.availableItemProblems ?? []
                ForEach(damage, id: \.itemProblemId) { element in
                    hSection {
                        hRow {
                            Circle()
                                .strokeBorder(hGrayscaleColorNew.greyScale1000)
                                .background(Circle().foregroundColor(retColor(text: element.itemProblemId)))
                                .frame(width: 28, height: 28)
                            hTextNew(element.displayName, style: .title3) /*TODO CHECK FONT SIZE */
                                .foregroundColor(hLabelColorNew.primary)
                        }
                        .withEmptyAccessory
                        .onTap {
                            let itemProblemId = element.itemProblemId
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
        .hUseNewStyle
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

    @hColorBuilder
    func retColor(text: String) -> some hColor {
        if selectedDamages.contains(text) {
            hLabelColorNew.primary
        } else {
            hGrayscaleColorNew.greyScale25
        }
    }

}

struct DamagePickerScreenView_Previews: PreviewProvider {
    static var previews: some View {
        DamamagePickerScreen()
    }
}

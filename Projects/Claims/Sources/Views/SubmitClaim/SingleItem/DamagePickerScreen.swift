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
                            hTextNew(element.displayName, style: .title3)
                                .foregroundColor(hLabelColorNew.primary)
                            Spacer()
                            Circle()
                                .strokeBorder(hBackgroundColorNew.semanticBorderTwo)
                                .background(Circle().foregroundColor(retColor(text: element.itemProblemId)))
                                .frame(width: 28, height: 28)
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
            VStack(spacing: 0) {
                hButton.LargeButtonFilled {
                    store.send(
                        .submitDamage(
                            damage: selectedDamages
                        )
                    )
                } content: {
                    hText(L10n.generalContinueButton)
                }
                hButton.LargeButtonText {
                    store.send(.navigationAction(action: .dismissScreen))
                } content: {
                    hTextNew(L10n.generalCancelButton, style: .body)
                }
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
            hBackgroundColorNew.opaqueOne
        }
    }
}

struct DamagePickerScreenView_Previews: PreviewProvider {
    static var previews: some View {
        DamamagePickerScreen()
    }
}

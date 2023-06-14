import SwiftUI
import hCore
import hCoreUI

struct SubmitClaimOccurrencePlusLocationScreen: View {
    @PresentableStore var store: SubmitClaimStore

    var body: some View {
        LoadingViewWithContent(.postDateOfOccurrenceAndLocation) {
            hForm {
            }
            .hFormTitle(.small, .title3, L10n.claimsLocatonOccuranceTitle)
            .hDisableScroll
            .hUseNewStyle
            .hFormAttachToBottom {
                VStack(spacing: 0) {
                    displayFieldsAndNotice
                    continueButton
                }
            }
        }
    }

    @ViewBuilder
    private var displayFieldsAndNotice: some View {
        hSection {
            PresentableStoreLens(
                SubmitClaimStore.self,
                getter: { state in
                    state.locationStep
                }
            ) { locationStep in

                hFloatingField(
                    value: locationStep?.getSelectedOption()?.displayName ?? "",
                    placeholder: L10n.Claims.Location.Screen.title,
                    onTap: {
                        store.send(.navigationAction(action: .openLocationPicker(type: .setLocation)))
                    }
                )
            }
        }
        .sectionContainerStyle(.transparent)
        .padding(.bottom, 8)

        hSection {
            PresentableStoreLens(
                SubmitClaimStore.self,
                getter: { state in
                    state.dateOfOccurenceStep
                }
            ) { dateOfOccurenceStep in

                hFloatingField(
                    value: dateOfOccurenceStep?.dateOfOccurence ?? "",
                    placeholder: L10n.Claims.Item.Screen.Date.Of.Incident.button,
                    onTap: {
                        store.send(
                            .navigationAction(action: .openDatePicker(type: .setDateOfOccurrence))
                        )
                    }
                )
            }
        }
        .sectionContainerStyle(.transparent)

        NoticeComponent(text: L10n.claimsDateNotSureNoticeLabel)
            .padding([.bottom, .top], 8)
    }

    @ViewBuilder
    private var continueButton: some View {
        hButton.LargeButtonFilled {
            store.send(.dateOfOccurrenceAndLocationRequest)
        } content: {
            hText(L10n.generalContinueButton, style: .body)
                .foregroundColor(hLabelColor.primary.inverted)
        }
        .frame(maxWidth: .infinity, alignment: .bottom)
        .padding([.leading, .trailing], 16)
        .padding(.bottom, 20)
    }
}

struct SubmitClaimOccurrencePlusLocationScreen_Previews: PreviewProvider {
    static var previews: some View {
        SubmitClaimOccurrencePlusLocationScreen()
    }
}

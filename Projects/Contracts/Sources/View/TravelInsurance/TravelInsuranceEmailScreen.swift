import Presentation
import SwiftUI
import hCore
import hCoreUI

struct TravelInsuranceEmailScreen: View {
    @PresentableStore var store: TravelInsuranceStore
    @State var email: String
    @State var emailError: String?

    private let masking = Masking(type: .email)
    public init() {
        let store: TravelInsuranceStore = globalPresentableStoreContainer.get()
        self.email = store.state.travelInsuranceConfigs?.email ?? ""
    }
    public var body: some View {

        hForm {
            hSection {
                hRow {
                    hText(L10n.TravelCertificate.emailStepDescription, style: .body)
                        .foregroundColor(hLabelColor.primary)
                }
            }
            .withoutBottomPadding
            hSection {
                hRow {
                    hText(L10n.TravelCertificate.emailStepDescription2, style: .body)
                        .foregroundColor(hLabelColor.primary)
                }
            }
        }
        .sectionContainerStyle(.opaque(useNewDesign: false))
        .hFormAttachToBottom {
            VStack {
                hRow {
                    VStack(alignment: .center) {
                        hTextField(
                            masking: masking,
                            value: $email,
                            placeholder: L10n.TravelCertificate.enterEmailPlaceholder
                        )
                        .hTextFieldOptions([.minimumHeight(height: 40)])
                        .hTextFieldError(emailError)
                        .multilineTextAlignment(.center)
                    }
                }
                .background(hBackgroundColor.tertiary)
                .clipShape(Squircle.default())
                .padding(.horizontal, 16)
                hSection {
                    hButton.LargeButtonFilled {
                        validateAndSubmit()
                    } content: {
                        hText(L10n.generalContinueButton, style: .body)
                            .foregroundColor(hLabelColor.primary.inverted)
                    }
                }
            }
        }
        .navigationTitle(L10n.TravelCertificate.cardTitle)
    }

    private func validateAndSubmit() {
        withAnimation {
            if masking.isValid(text: email) {
                emailError = nil
                store.send(.setEmail(value: email))
                UIApplication.dismissKeyboard()
            } else {
                emailError = L10n.myInfoEmailMalformedError
            }
        }
    }
}

struct TravelInsuranceEmailScreen_Previews: PreviewProvider {
    static var previews: some View {
        TravelInsuranceEmailScreen()
    }
}

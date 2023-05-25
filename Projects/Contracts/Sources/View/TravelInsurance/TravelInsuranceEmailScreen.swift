import SwiftUI
import hCore
import hCoreUI
import Presentation

struct TravelInsuranceEmailScreen: View {
    @PresentableStore var store: TravelInsuranceStore
    @State var email: String
    
    public init() {
        let store: TravelInsuranceStore = globalPresentableStoreContainer.get()
        self.email = store.state.travelInsuranceConfigs?.email ?? ""
    }
    public var body: some View {
        
        hForm {
            HStack(spacing: 0) {
                
                hText(L10n.TravelCertificate.emailStepDescription, style: .body)
                    .foregroundColor(hLabelColor.primary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding([.trailing, .leading], 12)
                    .padding([.top, .bottom], 16)
                    
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(hBackgroundColor.tertiary)
            .cornerRadius(12)
            .padding(.leading, 16)
            .padding(.trailing, 32)
            .padding(.top, 20)
            .hShadow()
        }
        .hFormAttachToBottom {
            VStack {
                HStack {
                    VStack {
                        hTextField(
                            masking: Masking(type: .email),
                            value: $email,
                            placeholder: L10n.emailPlaceholder
                        )
                        .multilineTextAlignment(.center)
                        .hTextFieldOptions([.minimumHeight(height: 60)])
                    }
                    .padding([.top, .bottom], 5)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .background(hBackgroundColor.tertiary)
                .cornerRadius(12)
                .padding([.leading, .trailing], 16)
                hButton.LargeButtonFilled {
                    store.send(.setEmail(value: email))
                    UIApplication.dismissKeyboard()
                } content: {
                    hText(L10n.generalContinueButton, style: .body)
                        .foregroundColor(hLabelColor.primary.inverted)
                }
                .frame(maxWidth: .infinity, alignment: .bottom)
                .padding([.leading, .trailing], 16)
                .padding(.bottom, 6)
            }
        }
        .navigationTitle(L10n.TravelCertificate.cardTitle)
    }
}

struct TravelInsuranceEmailScreen_Previews: PreviewProvider {
    static var previews: some View {
        TravelInsuranceEmailScreen()
    }
}

import SwiftUI
import hCore
import hCoreUI

struct StartDateScreen: View {
    @ObservedObject var vm: StartDateViewModel
    @EnvironmentObject var router: Router

    var body: some View {
        CertificateInputScreen(
            title: L10n.TravelCertificate.whenIsYourTrip,
            isLastScreenInFlow: false,
            elements: [.datePicker, .email, .infoCard],
            vm: .init(
                emailInput: $vm.email,
                emailError: $vm.emailError,
                dateInput: $vm.date,
                minStartDate: vm.specification.minStartDate,
                maxStartDate: vm.specification.maxStartDate,
                maxDuration: vm.specification.maxDuration,
                onButtonClick: {
                    Task {
                        await submit()
                    }
                }
            )
        )
    }

    func submit() async {
        if Masking(type: .email).isValid(text: vm.email) {
            DispatchQueue.main.async {
                self.vm.emailError = nil
                router.push(TravelCertificateRouterActions.whoIsTravelling(specifiction: vm.specification))
            }
        } else {
            DispatchQueue.main.async {
                withAnimation {
                    self.vm.emailError = L10n.myInfoEmailMalformedError
                }
            }
        }
    }
}

class StartDateViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var date: Date
    @Published var emailError: String?
    let specification: TravelInsuranceContractSpecification
    init(specification: TravelInsuranceContractSpecification) {
        self.specification = specification
        email = specification.email ?? ""
        date = specification.minStartDate
    }
}

struct StartDateView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            StartDateScreen(
                vm: .init(
                    specification: .init(
                        contractId: "",
                        displayName: "display name",
                        exposureDisplayName: "exposure display name",
                        minStartDate: Date(),
                        maxStartDate: Date().addingTimeInterval(60 * 60 * 24 * 10),
                        numberOfCoInsured: 0,
                        maxDuration: 45,
                        email: nil,
                        fullName: "full name"
                    )
                )
            )
        }
    }
}

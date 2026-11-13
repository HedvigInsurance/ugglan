import SwiftUI
import hCore
import hCoreUI

struct StartDateScreen: View {
    @Bindable var vm: StartDateViewModel
    @Environment(NavigationRouter.self) var router

    var body: some View {
        form
    }

    var form: some View {
        hForm {}
            .sectionContainerStyle(.transparent)
            .hFormTitle(title: .init(.small, .heading2, L10n.TravelCertificate.whenIsYourTrip, alignment: .leading))
            .hFormAttachToBottom {
                hSection {
                    VStack(spacing: .padding16) {
                        VStack(spacing: .padding4) {
                            hDatePickerField(
                                config: .init(
                                    minDate: vm.specification.minStartDate,
                                    maxDate: vm.specification.maxStartDate,
                                    placeholder: L10n.TravelCertificate.startDateTitle,
                                    title: L10n.TravelCertificate.startDateTitle
                                ),
                                selectedDate: vm.date
                            ) { date in
                                vm.date = date
                            }

                            hFloatingTextField(
                                masking: .init(type: .email),
                                value: $vm.email,
                                placeholder: L10n.emailRowTitle,
                                error: $vm.emailError
                            )
                        }
                        InfoCard(
                            text: L10n.TravelCertificate.startDateInfo(vm.specification.maxDuration),
                            type: .info
                        )
                        .accessibilitySortPriority(2)
                        hContinueButton { await submit() }
                    }
                }
            }
    }

    func submit() async {
        if Masking(type: .email).isValid(text: vm.email) {
            DispatchQueue.main.async {
                vm.emailError = nil
                router.push(TravelCertificateRouterActions.whoIsTravelling(specifiction: vm.specification))
            }
        } else {
            DispatchQueue.main.async {
                withAnimation {
                    vm.emailError = L10n.myInfoEmailMalformedError
                }
            }
        }
    }
}

@Observable
class StartDateViewModel {
    var email: String = ""
    var date: Date
    var emailError: String?
    let specification: TravelInsuranceContractSpecification
    init(specification: TravelInsuranceContractSpecification) {
        self.specification = specification
        email = specification.email ?? ""
        date = specification.minStartDate
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    return NavigationView {
        StartDateScreen(
            vm: .init(
                specification: .init(
                    contractId: "",
                    exposureDisplayName: "exposure display name",
                    minStartDate: Date(),
                    maxStartDate: Date().addingTimeInterval(60 * 60 * 24 * 10),
                    maxDuration: 45,
                    email: nil,
                    fullName: "full name"
                )
            )
        )
    }
}

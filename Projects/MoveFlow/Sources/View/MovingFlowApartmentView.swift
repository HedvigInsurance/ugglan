import Flow
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct MovingFlowApartmentView: View {
    @StateObject var vm = MovingFlowViewModel()

    var body: some View {
        hForm {
            hSection {
                VStack(spacing: 16) {
                    VStack(spacing: 4) {
                        addressField()
                        postalAndSquareField()
                        numberOfCoinsuredField()
                        accessDateField()
                    }
                    .trackLoading(MoveFlowStore.self, action: .submitMoveIntent)
                    InfoCard(text: L10n.changeAddressCoverageInfoText, type: .info)
                    LoadingButtonWithContent(
                        MoveFlowStore.self,
                        .submitMoveIntent
                    ) {
                        vm.continuePressed()
                    } content: {
                        hText(L10n.General.submit, style: .body)
                    }
                }
            }
            .padding(.bottom, 8)
            .padding(.top, 16)

        }
        .hFormTitle(.standard, .title1, L10n.changeAddressEnterNewAddressTitle)
        .sectionContainerStyle(.transparent)
        .hFormContentPosition(.bottom)
    }

    func addressField() -> some View {
        hFloatingTextField(
            masking: Masking(type: .address),
            value: $vm.address,
            equals: $vm.type,
            focusValue: .address,
            error: $vm.addressError
        )
    }

    func postalAndSquareField() -> some View {
        HStack(alignment: .top, spacing: 4) {
            hFloatingTextField(
                masking: Masking(type: .postalCode),
                value: $vm.postalCode,
                equals: $vm.type,
                focusValue: .postalCode,
                placeholder: L10n.changeAddressNewPostalCodeLabel,
                error: $vm.postalCodeError
            )

            hFloatingTextField(
                masking: Masking(type: .digits),
                value: $vm.squareArea,
                equals: $vm.type,
                focusValue: .squareArea,
                placeholder: L10n.changeAddressNewLivingSpaceLabel,
                suffix: L10n.changeAddressSizeSuffix,
                error: $vm.squareAreaError
            )
        }
    }

    func numberOfCoinsuredField() -> some View {
        hFloatingTextField(
            masking: Masking(type: .digits),
            value: $vm.nbOfCoInsured,
            equals: $vm.type,
            focusValue: .nbOfCoInsured,
            placeholder: L10n.changeAddressCoInsuredLabel,
            error: $vm.nbOfCoInsuredError
        )
    }

    func accessDateField() -> some View {
        let minStartDate = vm.store.state.movingFlowModel?.minMovingDate.localDateToDate
        let maxStartDate = vm.store.state.movingFlowModel?.maxMovingDate.localDateToDate

        return hDatePickerField(
            config: .init(
                minDate: minStartDate,
                maxDate: maxStartDate,
                placeholder: L10n.changeAddressMovingDateLabel,
                title: L10n.changeAddressMovingDateLabel
            ),
            selectedDate: vm.accessDate,
            error: $vm.accessDateError,
            onContinue: { date in
                vm.accessDate = date
                vm.type = nil
            },
            onShowDatePicker: {
                vm.type = .accessDate
            }
        )
    }
}

struct SelectAddress_Previews: PreviewProvider {
    static var previews: some View {
        Localization.Locale.currentLocale = .en_SE
        return MovingFlowApartmentView()
    }
}

enum MovingFlowSelectAddressFieldType: hTextFieldFocusStateCompliant {
    static var last: MovingFlowSelectAddressFieldType {
        return MovingFlowSelectAddressFieldType.accessDate
    }

    var next: MovingFlowSelectAddressFieldType? {
        switch self {
        case .address:
            return .postalCode
        case .postalCode:
            return .squareArea
        case .squareArea:
            return .nbOfCoInsured
        case .nbOfCoInsured:
            return .accessDate
        case .accessDate:
            return nil
        }
    }

    case address
    case postalCode
    case squareArea
    case nbOfCoInsured
    case accessDate

}

enum FieldType {
    case address
    case postal
    case square
    case nbOfCoinsured
}

class MovingFlowViewModel: ObservableObject {
    @Published var type: MovingFlowSelectAddressFieldType?
    @Published var address: String = ""
    @Published var postalCode: String = ""
    @Published var squareArea: String = ""
    @Published var nbOfCoInsured: String = ""
    @Published var accessDate: Date?

    @Published var addressError: String?
    @Published var postalCodeError: String?
    @Published var squareAreaError: String?
    @Published var nbOfCoInsuredError: String?
    @Published var accessDateError: String?

    @Inject var octopus: hOctopus
    @PresentableStore var store: MoveFlowStore

    var disposeBag = DisposeBag()
    func continuePressed() {
        if isInputValid() {
            store.setLoading(for: .submitMoveIntent)
            let input = OctopusGraphQL.MoveIntentRequestInput(
                moveToAddress: .init(
                    street: address,
                    postalCode: postalCode
                ),
                moveFromAddressId: store.state.movingFlowModel?.currentHomeAddresses.first?.id ?? "",
                movingDate: accessDate?.localDateString ?? "",
                numberCoInsured: Int(nbOfCoInsured) ?? 0,
                squareMeters: Int(squareArea) ?? 0,
                apartment: .init(subType: .own, isStudent: false)
            )

            let mutation = OctopusGraphQL.MoveIntentRequestMutation(
                intentId: store.state.movingFlowModel?.id ?? "",
                input: input
            )
            disposeBag += octopus.client.perform(mutation: mutation)
                .onValue({ [weak self] value in
                    if let fragment = value.moveIntentRequest.moveIntent?.fragments.moveIntentFragment {
                        let model = MovingFlowModel(from: fragment)
                        self?.store.send(.setMoveIntent(with: model))
                        self?.store.send(.navigation(action: .openConfirmScreen))
                        self?.store.removeLoading(for: .submitMoveIntent)
                    } else if let error = value.moveIntentRequest.userError?.message {
                        self?.store.setError(error, for: .submitMoveIntent)
                    }
                })
                .onError({ [weak self] error in
                    self?.store.setError(L10n.generalError, for: .submitMoveIntent)
                })
        }
    }

    private func isInputValid() -> Bool {
        func validate() -> Bool {
            withAnimation {
                addressError = !address.isEmpty ? nil : L10n.genericErrorInputRequired
                postalCodeError = !postalCode.isEmpty ? nil : L10n.genericErrorInputRequired
                squareAreaError = !squareArea.isEmpty ? nil : L10n.genericErrorInputRequired
                nbOfCoInsuredError = !nbOfCoInsured.isEmpty ? nil : L10n.genericErrorInputRequired
                accessDateError = accessDate?.localDateString != nil ? nil : L10n.genericErrorInputRequired
                return addressError == nil && postalCodeError == nil && squareAreaError == nil
                    && nbOfCoInsuredError == nil && accessDateError == nil
            }
        }
        return validate()
    }
}

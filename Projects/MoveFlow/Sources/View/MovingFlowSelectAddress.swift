import Flow
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct MovingFlowSelectAddress: View {
    @StateObject var vm = MovingFlowViewModel()

    var body: some View {
        hForm {
            hSection {
                VStack(spacing: 4) {
                    addressField()
                    postalAndSquareField()
                    numberOfCoinsuredField()
                    accessDateField()
                }
            }
            .sectionContainerStyle(.transparent)
        }
        .hFormTitle(.standard, .title3, L10n.changeAddressEnterNewAddressTitle)
        .hFormAttachToBottom {
            hButton.LargeButton(type: .primary) {
                vm.continuePressed()
            } content: {
                hText(L10n.generalContinueButton, style: .body)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
        }
    }

    func addressField() -> some View {
        hFloatingTextField(
            masking: Masking(type: .address),
            value: $vm.address,
            equals: $vm.type,
            focusValue: .address
        )
    }

    func postalAndSquareField() -> some View {
        HStack(spacing: 4) {
            hFloatingTextField(
                masking: Masking(type: .postalCode),
                value: $vm.postalCode,
                equals: $vm.type,
                focusValue: .postalCode,
                placeholder: L10n.changeAddressNewPostalCodeLabel
            )

            hFloatingTextField(
                masking: Masking(type: .digits),
                value: $vm.squareArea,
                equals: $vm.type,
                focusValue: .squareArea,
                placeholder: L10n.changeAddressNewLivingSpaceLabel
            )
        }
    }

    func numberOfCoinsuredField() -> some View {
        HStack(spacing: 0) {
            hFloatingField(value: vm.nbOfCoInsured, placeholder: L10n.changeAddressCoInsuredLabel) {
                vm.increaseNumberOfCoinsured()
            }
            Spacer()

            Button {
                vm.decreaseNumberOfCoinsured()
            } label: {
                Image(uiImage: hCoreUIAssets.minusSmall.image)
                    .foregroundColor(
                        hGrayscaleColorNew.greyScale1000.opacity((Int(vm.nbOfCoInsured) ?? 0) == 0 ? 0.4 : 1)
                    )

            }
            .frame(width: 30, height: 60)
            .disabled(Int(vm.nbOfCoInsured) == 0)

            Button {
                vm.increaseNumberOfCoinsured()
            } label: {
                Image(uiImage: hCoreUIAssets.plusSmall.image)
                    .foregroundColor(
                        hGrayscaleColorNew.greyScale1000.opacity((Int(vm.nbOfCoInsured) ?? 0) >= 5 ? 0.4 : 1)
                    )
                    .padding(.trailing, 16)
            }
            .frame(width: 30, height: 60)
            .disabled(Int(vm.nbOfCoInsured) ?? 0 >= 5)

        }
    }

    func accessDateField() -> some View {
        hDatePickerField(
            config: .init(
                placeholder: L10n.changeAddressMovingDateLabel,
                title: L10n.changeAddressMovingDateLabel
            ),
            selectedDate: vm.accessDate
        ) { date in
            vm.accessDate = date
        }
    }
}

struct SelectAddress_Previews: PreviewProvider {
    static var previews: some View {
        MovingFlowSelectAddress()
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
    @Inject var octopus: hOctopus
    @PresentableStore var store: MoveFlowStore

    var disposeBag = DisposeBag()
    func increaseNumberOfCoinsured() {
        let numberOfConisured = Int(nbOfCoInsured) ?? 0
        if numberOfConisured < 5 {
            withAnimation {
                nbOfCoInsured = "\(numberOfConisured + 1)"
            }
        }
    }

    func decreaseNumberOfCoinsured() {
        let numberOfConisured = Int(nbOfCoInsured) ?? 0
        withAnimation {
            if numberOfConisured > 1 {
                nbOfCoInsured = "\(numberOfConisured - 1)"
            } else {
                nbOfCoInsured = ""
            }
        }
    }

    func continuePressed() {
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
                let ss = ""
                self?.store.send(.navigation(action: .openConfirmScreen))
            })
            .onError({ error in
                let ssss = ""
            })
    }
}

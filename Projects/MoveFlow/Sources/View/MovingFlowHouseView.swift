import PresentableStore
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct MovingFlowHouseView: View {
    @ObservedObject var houseInformationInputvm: HouseInformationInputModel
    @EnvironmentObject var movingFlowNavigationVm: MovingFlowNavigationViewModel
    @EnvironmentObject var router: Router

    init(houseInformationInputvm: HouseInformationInputModel) {
        self.houseInformationInputvm = houseInformationInputvm
    }

    var body: some View {
        form.loadingButtonWithErrorHandling($houseInformationInputvm.viewState)
            .hErrorViewButtonConfig(
                .init(
                    actionButton: .init(buttonAction: {
                        houseInformationInputvm.error = nil
                    }),
                    dismissButton: nil
                )
            )
            .onDisappear {
                houseInformationInputvm.clearErrors()
            }
    }

    var form: some View {
        hForm {
            VStack {
                VStack(spacing: 16) {
                    VStack(spacing: 8) {
                        yearOfConstructionField
                        ancillaryAreaField
                        bathroomsField
                        isSubleted
                        extraBuildingTypes
                    }
                    .disabled(houseInformationInputvm.viewState == .loading)
                    hSection {
                        InfoCard(text: L10n.changeAddressCoverageInfoText, type: .info)
                    }
                    hSection {
                        hButton.LargeButton(type: .primary) {
                            continuePressed()
                        } content: {
                            hText(L10n.saveAndContinueButtonLabel, style: .body1)
                        }
                    }

                }
            }
            .padding(.bottom, .padding8)
            .padding(.top, .padding16)

        }
        .hFormTitle(
            title: .init(
                .small,
                .heading2,
                L10n.movingEmbarkTitle,
                alignment: .leading
            ),
            subTitle: .init(
                .standard,
                .heading2,
                L10n.changeAddressInformationAboutYourHouse
            )
        )
        .sectionContainerStyle(.transparent)
        .presentableStoreLensAnimation(.default)
    }

    private var yearOfConstructionField: some View {
        hSection {
            hFloatingTextField(
                masking: Masking(type: .digits),
                value: $houseInformationInputvm.yearOfConstruction,
                equals: $houseInformationInputvm.type,
                focusValue: .yearOfConstruction,
                placeholder: L10n.changeAddressYearOfConstructionLabel,
                error: $houseInformationInputvm.yearOfConstructionError
            )
        }
    }

    private var ancillaryAreaField: some View {
        hSection {
            hFloatingTextField(
                masking: Masking(type: .digits),
                value: $houseInformationInputvm.ancillaryArea,
                equals: $houseInformationInputvm.type,
                focusValue: .ancillaryArea,
                placeholder: L10n.changeAddressAncillaryAreaLabel,
                suffix: "m\u{00B2}",
                error: $houseInformationInputvm.ancillaryAreaError
            )
        }
    }

    private var bathroomsField: some View {
        hSection {
            hCounterField(
                value: $houseInformationInputvm.bathrooms,
                placeholder: L10n.changeAddressBathroomsLabel,
                minValue: 1,
                maxValue: 10,
                error: $houseInformationInputvm.bathroomsError
            ) { value in
                houseInformationInputvm.type = nil
                if value == 0 {
                    return nil
                } else {
                    return "\(value)"
                }
            }
        }
        .sectionContainerStyle(.transparent)

    }

    private var extraBuildingTypes: some View {
        hSection {
            hRow {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        hText(L10n.changeAddressExtraBuildingsLabel, style: .label)
                        Spacer()
                    }
                    ForEach(Array(houseInformationInputvm.extraBuildings.enumerated()), id: \.element.id) {
                        offset,
                        extraBuilding in
                        HStack {
                            VStack(alignment: .leading, spacing: 0) {
                                hText(extraBuilding.type.translatedValue, style: .body1)
                                HStack(spacing: 0) {
                                    hText(extraBuilding.descriptionText, style: .label)
                                        .foregroundColor(hTextColor.Opaque.secondary)
                                }
                            }
                            Spacer()
                            Button {
                                withAnimation {
                                    houseInformationInputvm.remove(extraBuilding: extraBuilding)
                                }
                            } label: {
                                Image(uiImage: hCoreUIAssets.closeSmall.image)
                                    .resizable()
                                    .frame(width: 16, height: 16)
                                    .foregroundColor(hTextColor.Opaque.primary)
                            }
                        }
                        .padding(.vertical, .padding12)
                        if offset + 1 < houseInformationInputvm.extraBuildings.count {
                            Divider()
                        }
                    }
                    hButton.MediumButton(type: .primaryAlt) {
                        addExtraBuilding()
                    } content: {
                        HStack {
                            Image(uiImage: hCoreUIAssets.plusSmall.image)
                                .resizable()
                                .frame(width: .padding16, height: .padding16)
                            hText(L10n.changeAddressAddBuilding)
                        }
                    }
                    .hButtonDontShowLoadingWhenDisabled(true)
                    .fixedSize(horizontal: true, vertical: false)
                    .hUseLightMode
                    .padding(.top, .padding8)

                }
            }
            .verticalPadding(0)
            .padding(.top, .padding12)
            .padding(.bottom, .padding16)
        }
        .sectionContainerStyle(.opaque)
        .padding(.top, .padding6)
    }

    private var isSubleted: some View {
        CheckboxToggleView(
            title: L10n.changeAddressSubletLabel,
            isOn: $houseInformationInputvm.isSubleted.animation(.default)
        )
        .hFieldSize(.large)
        .onTapGesture {
            withAnimation {
                houseInformationInputvm.type = nil
                houseInformationInputvm.isSubleted.toggle()
            }
        }
    }

    func addExtraBuilding() {
        UIApplication.dismissKeyboard()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            movingFlowNavigationVm.isAddExtraBuildingPresented = houseInformationInputvm
        }
    }

    func continuePressed() {
        if houseInformationInputvm.isInputValid() {
            Task {
                let movingFlowData = try await houseInformationInputvm.requestMoveIntent(
                    intentId: movingFlowNavigationVm.movingFlowVm?.id ?? "",
                    addressInputModel: movingFlowNavigationVm.addressInputModel
                )
                movingFlowNavigationVm.movingFlowVm = movingFlowData

                if let changeTierModel = movingFlowData?.changeTier {
                    router.push(MovingFlowRouterActions.selectTier(changeTierModel: changeTierModel))
                } else {
                    router.push(MovingFlowRouterActions.confirm)
                }
            }
        }
    }
}

struct MovingFlowHouseView_Previews: PreviewProvider {
    static var previews: some View {
        Localization.Locale.currentLocale.send(.nb_NO)
        return MovingFlowHouseView(houseInformationInputvm: HouseInformationInputModel())
    }
}

enum MovingFlowHouseFieldType: hTextFieldFocusStateCompliant {
    static var last: MovingFlowHouseFieldType {
        return MovingFlowHouseFieldType.ancillaryArea
    }

    var next: MovingFlowHouseFieldType? {
        switch self {
        case .yearOfConstruction:
            return .ancillaryArea
        case .ancillaryArea:
            return nil
        }
    }

    case yearOfConstruction
    case ancillaryArea
}

public typealias ExtraBuildingType = String
public class HouseInformationInputModel: ObservableObject, Equatable, Identifiable {
    public static func == (lhs: HouseInformationInputModel, rhs: HouseInformationInputModel) -> Bool {
        return true
    }

    @Inject private var service: MoveFlowClient
    @Published var type: MovingFlowHouseFieldType?
    @Published var yearOfConstruction: String = ""
    @Published var ancillaryArea: String = ""
    @Published var bathrooms: Int = 1
    @Published var isSubleted = false
    @Published var yearOfConstructionError: String?
    @Published var ancillaryAreaError: String?
    @Published var bathroomsError: String?
    @Published var extraBuildings: [ExtraBuilding] = []
    @Published var error: String?
    @Published var viewState: ProcessingState = .success

    init() {}

    @MainActor
    func requestMoveIntent(intentId: String, addressInputModel: AddressInputModel) async throws -> MovingFlowModel? {
        withAnimation {
            self.viewState = .loading
        }

        do {
            let movingFlowData = try await service.requestMoveIntent(
                intentId: intentId,
                addressInputModel: addressInputModel,
                houseInformationInputModel: self
            )

            withAnimation {
                self.viewState = .success
            }

            return movingFlowData
        } catch {
            self.viewState = .error(errorMessage: error.localizedDescription)
        }
        return nil
    }

    func isInputValid() -> Bool {
        func validate() -> Bool {
            withAnimation {
                yearOfConstructionError = !yearOfConstruction.isEmpty ? nil : L10n.changeAddressYearOfConstructionError
                ancillaryAreaError = !ancillaryArea.isEmpty ? nil : L10n.changeAddressAncillaryAreaError
                bathroomsError = bathrooms == 0 ? L10n.changeAddressBathroomsError : nil
                return yearOfConstructionError == nil && ancillaryAreaError == nil && bathroomsError == nil
            }
        }
        return validate()
    }

    func remove(extraBuilding: ExtraBuilding) {
        UIApplication.dismissKeyboard()
        extraBuildings.removeAll(where: { $0.id == extraBuilding.id })
    }

    func clearErrors() {
        error = nil
        yearOfConstructionError = nil
        ancillaryAreaError = nil
        bathroomsError = nil
    }
}

struct ExtraBuilding: Identifiable {
    let id: String
    let type: ExtraBuildingType
    let livingArea: Int
    let connectedToWater: Bool

    var descriptionText: String {
        var elements: [String] = []
        elements.append("\(self.livingArea) \(L10n.changeAddressSizeSuffix)")
        if connectedToWater {
            elements.append(L10n.changeAddressExtraBuildingsWaterLabel)
        }
        return elements.joined(separator: " ∙ ")
    }
}

extension ExtraBuildingType {
    var translatedValue: String {
        let key = "FIELD_EXTRA_BUIDLINGS_\(self.uppercased())_LABEL"
        let translatedValue = L10nDerivation.init(table: "", key: key, args: []).render()
        return key == translatedValue ? self : translatedValue
    }
}

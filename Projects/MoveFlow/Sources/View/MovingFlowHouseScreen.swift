import SwiftUI
import hCore
import hCoreUI

struct MovingFlowHouseScreen: View {
    @ObservedObject var houseInformationInputvm: HouseInformationInputModel
    @EnvironmentObject var movingFlowNavigationVm: MovingFlowNavigationViewModel
    @EnvironmentObject var router: Router

    var body: some View {
        form.loadingWithButtonLoading($houseInformationInputvm.viewState)
            .hStateViewButtonConfig(
                .init(
                    actionButton: .init(buttonAction: {
                        houseInformationInputvm.viewState = .success
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
            VStack(spacing: 16) {
                VStack(spacing: 8) {
                    yearOfConstructionField
                    ancillaryAreaField
                    bathroomsField
                    isSubleted
                    extraBuildingTypes
                }
                .hFieldSize(.medium)
                .disabled(houseInformationInputvm.viewState == .loading)
            }
            .padding(.bottom, .padding8)
        }
        .hFormAlwaysAttachToBottom {
            hSection {
                hButton(
                    .large,
                    .primary,
                    content: .init(title: L10n.saveAndContinueButtonLabel),
                    {
                        continuePressed()
                    }
                )
            }
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
        .hFormContentPosition(.bottom)
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
                                hText(extraBuilding.type.displayName, style: .body1)
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
                                hCoreUIAssets.closeSmall.view
                                    .resizable()
                                    .frame(width: 16, height: 16)
                                    .foregroundColor(hTextColor.Opaque.primary)
                            }
                        }
                        .padding(.vertical, .padding12)
                        if offset + 1 < houseInformationInputvm.extraBuildings.count {
                            hRowDivider()
                                .hWithoutHorizontalPadding([.divider])
                        }
                    }
                    hButton(
                        .medium,
                        .primaryAlt,
                        content: .init(
                            title: L10n.changeAddressAddBuilding,
                            buttonImage: .init(
                                image: hCoreUIAssets.plusSmall.view,
                                alignment: .leading
                            )
                        ),
                        {
                            addExtraBuilding()
                        }
                    )
                    .hButtonDontShowLoadingWhenDisabled(true)
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

    @ViewBuilder
    private var isSubleted: some View {
        CheckboxToggleView(
            title: L10n.changeAddressSubletLabel,
            isOn: $houseInformationInputvm.isSubleted.animation(.default)
        )
        .onTapGesture {
            withAnimation {
                houseInformationInputvm.type = nil
                houseInformationInputvm.isSubleted.toggle()
            }
        }
        .accessibilityAddTraits(.isButton)
        .accessibilityAddTraits(.isButton)
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
                if let requestVm = await houseInformationInputvm.requestMoveIntent(
                    intentId: movingFlowNavigationVm.moveConfigurationModel?.id ?? "",
                    addressInputModel: movingFlowNavigationVm.addressInputModel,
                    selectedAddressId: movingFlowNavigationVm.selectedHomeAddress?.id ?? ""
                ) {
                    movingFlowNavigationVm.moveQuotesModel = requestVm

                    if let changeTierModel = requestVm.changeTierModel {
                        router.push(MovingFlowRouterActions.selectTier(changeTierModel: changeTierModel))
                    } else {
                        router.push(MovingFlowRouterActions.confirm)
                    }
                }
            }
        }
    }
}

#Preview {
    Localization.Locale.currentLocale.send(.sv_SE)
    Dependencies.shared.add(module: Module { () -> MoveFlowClient in MoveFlowClientDemo() })
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    return MovingFlowHouseScreen(houseInformationInputvm: HouseInformationInputModel())
        .environmentObject(MovingFlowNavigationViewModel())
}

enum MovingFlowHouseFieldType: hTextFieldFocusStateCompliant {
    static var last: MovingFlowHouseFieldType {
        MovingFlowHouseFieldType.ancillaryArea
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

public struct ExtraBuildingType: Sendable, Hashable {
    public let type: String
    public let displayName: String

    public init(type: String, displayName: String) {
        self.type = type
        self.displayName = displayName
    }
}

@MainActor
public class HouseInformationInputModel: ObservableObject, @preconcurrency Equatable, Identifiable {
    public static func == (_: HouseInformationInputModel, _: HouseInformationInputModel) -> Bool {
        true
    }

    @Inject private var service: MoveFlowClient
    @Published var type: MovingFlowHouseFieldType?
    @Published public var yearOfConstruction: String = ""
    @Published public var ancillaryArea: String = ""
    @Published public var bathrooms: Int = 1
    @Published public var isSubleted = false
    @Published var yearOfConstructionError: String?
    @Published var ancillaryAreaError: String?
    @Published var bathroomsError: String?
    @Published public var extraBuildings: [ExtraBuilding] = []
    @Published var viewState: ProcessingState = .success

    init() {}

    @MainActor
    func requestMoveIntent(
        intentId: String,
        addressInputModel: AddressInputModel,
        selectedAddressId: String
    ) async -> MoveQuotesModel? {
        withAnimation {
            self.viewState = .loading
        }

        do {
            let input = RequestMoveIntentInput(
                intentId: intentId,
                addressInputModel: addressInputModel,
                houseInformationInputModel: self,
                selectedAddressId: selectedAddressId
            )
            let movingFlowData = try await service.requestMoveIntent(input: input)

            withAnimation {
                self.viewState = .success
            }

            return movingFlowData
        } catch {
            viewState = .error(errorMessage: error.localizedDescription)
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
        viewState = .success
        yearOfConstructionError = nil
        ancillaryAreaError = nil
        bathroomsError = nil
    }
}

public struct ExtraBuilding: Identifiable {
    public let id: String
    public let type: ExtraBuildingType
    public let livingArea: Int
    public let connectedToWater: Bool

    var descriptionText: String {
        var elements: [String] = []
        elements.append("\(livingArea) \(L10n.changeAddressSizeSuffix)")
        if connectedToWater {
            elements.append(L10n.changeAddressExtraBuildingsWaterLabel)
        }
        return elements.displayName
    }
}

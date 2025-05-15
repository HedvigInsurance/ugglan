import Combine
import SwiftUI
import TagKit
import hCore
import hCoreUI

public struct ContractRow: View {
    @State var frameWidth: CGFloat = 0

    let terminationMessage: String?
    let displayNames: [String]
    let contractExposureName: String
    let activeFrom: String?
    let activeInFuture: Bool?
    let masterInceptionDate: String?
    let tierDisplayName: String?
    let typeOfContracts: [(type: TypeOfContract, id: String)]
    let onClick: ((String) -> Void)?

    public init(
        terminationMessage: String?,
        displayNames: [String],
        contractExposureName: String,
        activeFrom: String? = nil,
        activeInFuture: Bool? = nil,
        masterInceptionDate: String? = nil,
        tierDisplayName: String?,
        onClick: ((String) -> Void)? = nil,
        typeOfContracts: [(type: TypeOfContract, id: String)]
    ) {
        self.terminationMessage = terminationMessage
        self.displayNames = displayNames
        self.contractExposureName = contractExposureName
        self.activeFrom = activeFrom
        self.activeInFuture = activeInFuture
        self.masterInceptionDate = masterInceptionDate
        self.tierDisplayName = tierDisplayName
        self.typeOfContracts = typeOfContracts

        self.onClick = onClick
    }

    public var body: some View {
        SwiftUI.Button {
        } label: {
            EmptyView()
        }
        .buttonStyle(
            ContractRowButtonStyle(
                displayNames: displayNames,
                contractExposureName: contractExposureName,
                terminationMessage: terminationMessage,
                activeFrom: activeFrom,
                activeInFuture: activeInFuture,
                masterInceptionDate: masterInceptionDate,
                tierDisplayName: tierDisplayName,
                typeOfContracts: typeOfContracts,
                onClick: onClick
            )
        )
        .background(
            GeometryReader { geo in
                Color.clear.onReceive(Just(geo.size.width)) { width in
                    self.frameWidth = width
                }
            }
        )
        .hShadow()
    }
}

private struct ContractRowButtonStyle: SwiftUI.ButtonStyle {
    let displayNames: [String]
    let contractExposureName: String
    let terminationMessage: String?
    let activeFrom: String?
    let activeInFuture: Bool?
    let masterInceptionDate: String?
    let tierDisplayName: String?
    private let tagsToShow: [(text: String, type: PillType)]
    let typeOfContracts: [(type: TypeOfContract, id: String)]

    let onClick: ((String) -> Void)?

    public init(
        displayNames: [String],
        contractExposureName: String,
        terminationMessage: String? = nil,
        activeFrom: String? = nil,
        activeInFuture: Bool? = nil,
        masterInceptionDate: String? = nil,
        tierDisplayName: String?,
        typeOfContracts: [(type: TypeOfContract, id: String)],
        onClick: ((String) -> Void)?
    ) {
        self.displayNames = displayNames
        self.contractExposureName = contractExposureName
        self.terminationMessage = terminationMessage

        self.activeFrom = activeFrom
        self.activeInFuture = activeInFuture
        self.masterInceptionDate = masterInceptionDate
        self.tierDisplayName = tierDisplayName
        self.typeOfContracts = typeOfContracts
        self.onClick = onClick
        var tagsToShow = [(text: String, type: PillType)]()
        if let tierDisplayName {
            tagsToShow.append((tierDisplayName, .tier))
        }
        if let terminationMessage {
            tagsToShow.append((terminationMessage, .text))
        } else if let activeFrom {
            tagsToShow.append(
                (
                    L10n.dashboardInsuranceStatusActiveUpdateDate(
                        activeFrom.localDateToDate?.displayDateDDMMMYYYYFormat ?? ""
                    ), .text
                )
            )
        } else if activeInFuture ?? false {
            tagsToShow.append(
                (
                    L10n.contractStatusActiveInFuture(
                        masterInceptionDate?.localDateToDate?.displayDateDDMMMYYYYFormat ?? ""
                    ), .text
                )
            )
        } else if masterInceptionDate == nil {
            tagsToShow.append((L10n.contractStatusPending, .text))
        } else {
            tagsToShow.append((L10n.dashboardInsuranceStatusActive, .text))
        }
        self.tagsToShow = tagsToShow
    }

    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: .padding6) {
                TagList(
                    tags: tagsToShow.map({ $0.text }),
                    horizontalSpacing: .padding6 / 2,
                    verticalSpacing: .padding6 / 2
                ) { tag in
                    StatusPill(text: tag, type: tagsToShow.first(where: { $0.text == tag })?.type ?? .text)
                }
                .padding(.vertical, -.padding6 / 2)
                .padding(.horizontal, -.padding6 / 2)
                Spacer()
                logo
            }
            Spacer()
            HStack {
                VStack(alignment: .leading) {
                    ForEach(displayNames, id: \.self) { text in
                        hText(text)
                    }
                }
                .foregroundColor(textColor)
                Spacer()
            }
        }
        .padding(.padding16)
        .frame(minHeight: 300)
        .background(
            background
        )
        .border(hBorderColor.primary, width: 0.5)
        .clipShape(RoundedRectangle(cornerRadius: .cornerRadiusL))
        .contentShape(Rectangle())
    }

    @ViewBuilder var background: some View {
        ZStack {
            homeView
            dogView
            carView
        }
    }

    @ViewBuilder
    private var homeView: some View {
        if contractTypes.contains(.home) {
            hCoreUIAssets.home.view
                .resizable()
                .aspectRatio(contentMode: .fit)
                .scaleEffect(1.1)
                .onTapGesture {
                    if let contractType = typeOfContracts.first(where: { $0.type.isHomeInsurance }) {
                        onClick?(contractType.id)
                    }
                }
        }
    }

    @ViewBuilder
    private var dogView: some View {
        if contractTypes.contains(.dog) {
            if displayNames.count == 1 {
                hCoreUIAssets.dog.view
                    .resizable()
                    .scaleEffect(0.7)
                    .aspectRatio(contentMode: .fit)
            } else {
                hCoreUIAssets.dog.view
                    .resizable()
                    .scaleEffect(0.5)
                    .aspectRatio(contentMode: .fit)
                    .padding(.top, 170)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.trailing, 100)
                    .onTapGesture {
                        if let contractType = typeOfContracts.first(where: { $0.type.isPetInsurance }) {
                            onClick?(contractType.id)
                        }
                    }
            }
        }
    }

    @ViewBuilder
    private var carView: some View {
        if contractTypes.contains(.car) {
            if displayNames.count == 1 {
                hCoreUIAssets.car.view
                    .resizable()
                    .scaleEffect(0.8)
                    .aspectRatio(contentMode: .fit)
            } else {
                hCoreUIAssets.car.view
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(1.4)
                    .padding(.top, 150)
                    .padding(.leading, 240)
                    .onTapGesture {
                        if let contractType = typeOfContracts.first(where: { $0.type.isCarInsurance }) {
                            onClick?(contractType.id)
                        }
                    }
            }
        }
    }

    private var contractImageView: Image {
        if contractTypes.count == 3 {
            return hCoreUIAssets.homeCarDog.view
        } else if contractTypes.contains(.home) {
            return hCoreUIAssets.home.view
        } else if contractTypes.contains(.dog) {
            return hCoreUIAssets.dog.view
        } else {
            return hCoreUIAssets.car.view
        }
    }

    private var contractTypes: [ContractType] {
        var listOfContracts: [ContractType] = []

        let hasHomeInsurance = typeOfContracts.filter { contract in
            switch contract.type {
            case .seHouseBas, .seHouse, .seHouseMax, .seApartmentBrfBas, .seApartmentBrf, .seApartmentBrfMax,
                .seApartmentRentBas, .seApartmentRent, .seApartmentRentMax, .seApartmentStudentBrf,
                .seApartmentStudentRent, .seGroupApartmentBrf, .seGroupApartmentRent, .seQasaShortTermRental,
                .seQasaLongTermRental:
                return true
            default:
                return false
            }
        }

        if !hasHomeInsurance.isEmpty {
            listOfContracts.append(.home)
        }

        let hasPetInsurance = typeOfContracts.filter { contract in
            switch contract.type {
            case .seDogBasic, .seDogStandard, .seDogPremium, .seCatBasic, .seCatStandard, .seCatPremium:
                return true
            default:
                return false
            }
        }

        if !hasPetInsurance.isEmpty {
            listOfContracts.append(.dog)
        }

        let hasCarInsurance = typeOfContracts.filter { contract in
            switch contract.type {
            case .seCarTraffic, .seCarHalf, .seCarFull, .seCarTrialFull, .seCarTrialHalf:
                return true
            default:
                return false
            }
        }

        if !hasCarInsurance.isEmpty {
            listOfContracts.append(.car)
        }

        return listOfContracts
    }

    @ViewBuilder var logo: some View {
        Image(uiImage: HCoreUIAsset.helipadBig.image)
            .resizable()
            .frame(width: 24, height: 24)
            .foregroundColor(hFillColor.Opaque.black)
            .colorScheme(.dark)
    }

    @hColorBuilder
    private var textColor: some hColor {
        if displayNames.count == 1 && !contractTypes.contains(.home) {
            hTextColor.Opaque.black
        } else {
            hTextColor.Opaque.white
        }
    }
}

public enum ContractType {
    case home
    case dog
    case car
}

@MainActor
private enum PillType {
    case text
    case tier

    @hColorBuilder
    var getBackgroundColor: some hColor {
        switch self {
        case .text:
            hFillColor.Translucent.tertiary
        case .tier:
            hFillColor.Translucent.secondary
        }
    }
}

private struct StatusPill: View {
    var text: String
    var type: PillType
    @Environment(\.sizeCategory) private var sizeCategory

    var body: some View {
        VStack {
            hText(text, style: .label)
        }
        .padding(.vertical, 3)
        .padding(.horizontal, .padding6)
        .foregroundColor(hTextColor.Opaque.white)
        .background(type.getBackgroundColor).colorScheme(.light)
        .cornerRadius(.cornerRadiusS)
    }
}

#Preview {
    hSection {
        ContractRow(
            terminationMessage: "Active",
            displayNames: ["Home Insurance"],
            contractExposureName: "Address ∙ Coverage",
            tierDisplayName: "tier display name",
            typeOfContracts: [(.seHouse, ""), (.seCarFull, ""), (.seDogBasic, "")]
        )
    }
}

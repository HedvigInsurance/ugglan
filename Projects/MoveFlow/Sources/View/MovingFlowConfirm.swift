import Flow
import Presentation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct MovingFlowConfirm: View {
    private let whatIsCoveredId = "whatIsCoveredId"
    @PresentableStore var store: MoveFlowStore
    @State var isMultipleOffer = true
    @State var selectedInsurances: [String] = [""]
    @State var selectedFaq: [String] = [""]
    @State var showCoverage = false
    var body: some View {
        ScrollViewReader { proxy in
            hForm {
                PresentableStoreLens(
                    MoveFlowStore.self,
                    getter: { state in
                        state.movingFlowModel
                    }
                ) { movingFlowModel in
                    if let movingFlowModel {
                        VStack(spacing: 16) {
                            ForEach(movingFlowModel.quotes, id: \.address) { quote in
                                contractInfoView(for: quote)
                            }
                            noticeComponent
                            totalAmountComponent
                            buttonComponent(proxy: proxy)
                                .padding(.top, 126)
                                .padding(.bottom, 48)
                            if showCoverage {
                                ZStack {
                                    VStack(spacing: 32) {
                                        ForEach(movingFlowModel.quotes, id: \.address) { quote in
                                            whatIsCovered(for: quote)
                                        }
                                    }
                                }
                                .padding(.top, 8)
                                .id(whatIsCoveredId)
                                chatComponent
                            }

                        }
                    }
                }
            }
        }
    }

    private func contractInfoView(for quote: Quote) -> some View {
        hSection {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(uiImage: quote.contractType?.pillowType.bgImage ?? hCoreUIAssets.bigPillowCar.image)
                        .resizable()
                        .frame(width: 48, height: 48)
                    VStack(alignment: .leading) {
                        hText(quote.displayName)
                        hText(L10n.changeAddressActivationDate(quote.startDate))
                            .foregroundColor(hTextColorNew.secondary)
                    }
                    Spacer()
                }
                Divider()
                let index = selectedInsurances.firstIndex(of: quote.displayName)
                let isExpanded = index != nil
                HStack(spacing: 8) {
                    hText(L10n.changeAddressDetails, style: .body)
                    Image(uiImage: hCoreUIAssets.chevronDown.image)
                        .resizable()
                        .frame(width: 16, height: 16)
                        .foregroundColor(hTextColorNew.tertiary)
                        .rotationEffect(isExpanded ? Angle(degrees: -180) : Angle(degrees: 0))
                    Spacer()
                    hText("\(quote.premium.formattedAmountWithoutDecimal)\(L10n.perMonth)")
                }
                if isExpanded {
                    VStack(alignment: .leading) {
                        ForEach(quote.detailsInfo, id: \.key) { keyValue in
                            HStack {
                                hText(keyValue.key, style: .body)
                                Spacer()
                                hText(keyValue.value, style: .body)
                            }
                        }
                    }
                    .foregroundColor(hTextColorNew.secondary)
                }
            }
            .padding(16)
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation {
                    let index = selectedInsurances.firstIndex(of: quote.displayName)
                    if let index {
                        selectedInsurances.remove(at: index)
                    } else {
                        selectedInsurances.append(quote.displayName)
                    }
                }
            }
        }
    }

    private var noticeComponent: some View {
        hSection {
            InfoCard(
                text:
                    L10n.changeAddressAccidentNotice,
                type: .info
            )
        }
        .sectionContainerStyle(.transparent)
    }

    private func buttonComponent(proxy: ScrollViewProxy) -> some View {
        hSection {
            VStack(spacing: 8) {
                hButton.LargeButton(type: .primary) {
                    store.send(.confirmMoveIntent)
                    store.send(.navigation(action: .openProcessingView))
                } content: {
                    hText(L10n.changeAddressAcceptOffer, style: .body)
                }

                hButton.LargeButton(type: .ghost) {

                    withAnimation {
                        showCoverage = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        withAnimation {
                            proxy.scrollTo(whatIsCoveredId, anchor: .top)
                        }
                    }
                } content: {
                    hText(L10n.changeAddressViewCoverage, style: .body)
                }
            }
        }
        .sectionContainerStyle(.transparent)
    }
    private var totalAmountComponent: some View {
        PresentableStoreLens(
            MoveFlowStore.self,
            getter: { state in
                state.movingFlowModel
            }
        ) { movingFlowModel in
            hSection {
                HStack {
                    hText(L10n.changeAddressTotal, style: .body)
                    Spacer()
                    hText("\(movingFlowModel?.total.formattedAmountWithoutDecimal ?? "")\(L10n.perMonth)", style: .body)
                }
            }
            .sectionContainerStyle(.transparent)
        }
    }

    @ViewBuilder
    func whatIsCovered(for quote: Quote) -> some View {
        VStack(spacing: 0) {
            hSection {
                VStack {
                    hText(quote.displayName, style: .standard)
                        .padding([.top, .bottom], 4)
                        .padding([.leading, .trailing], 8)

                }
                .background(
                    Squircle.default()
                        .fill(hBlueColorNew.blue100)
                )
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .sectionContainerStyle(.transparent)
            Spacing(height: 16)
            hSection(quote.insurableLimits, id: \.label) { field in
                hRow {
                    hText(field.label, style: .body)
                    Spacer()
                    hText(field.limit, style: .body)
                    Image(uiImage: hCoreUIAssets.infoSmall.image)
                        .resizable()
                        .frame(width: 14, height: 14)
                        .foregroundColor(hGrayscaleColorNew.greyScale700)
                }
                .noHorizontalPadding()
            }
            .sectionContainerStyle(.transparent)
            Spacing(height: 32)
            hSection(quote.documents, id: \.displayName) { document in
                hRow {
                    HStack(spacing: 1) {
                        hText(document.displayName)
                        if #available(iOS 16.0, *) {
                            hText(L10n.documentPdfLabel, style: .footnote)
                                .baselineOffset(6.0)
                        }
                    }
                }
                .withCustomAccessory {
                    Spacer()
                    Image(uiImage: hCoreUIAssets.neArrowSmall.image)
                }
            }
            Spacing(height: 40)
            faqsComponent(for: quote)
        }
    }

    @ViewBuilder
    func faqsComponent(for quote: Quote) -> some View {
        if !quote.faqs.isEmpty {
            hSection {
                VStack(alignment: .leading, spacing: 0) {
                    hText(L10n.changeAddressQa)
                    hText(L10n.changeAddressFaqSubtitle).foregroundColor(hTextColorNew.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .sectionContainerStyle(.transparent)
            Spacing(height: 24)
            VStack(spacing: 4) {
                ForEach(quote.faqs, id: \.title) { faq in
                    let id = "\(quote.id) \(faq.title)"
                    let index = selectedFaq.firstIndex(of: id)
                    let expanded = index != nil
                    hSection {
                        VStack(spacing: 0) {
                            hRow {
                                hText(faq.title)
                                Spacer()
                            }
                            .withCustomAccessory {
                                Image(
                                    uiImage: expanded ? hCoreUIAssets.minusSmall.image : hCoreUIAssets.plusSmall.image
                                )
                                .resizable()
                                .frame(width: 16, height: 16)
                            }
                            .verticalPadding(12)
                            if expanded, let description = faq.description {
                                hRow {
                                    hText(description, style: .standardSmall).foregroundColor(hTextColorNew.secondary)
                                }
                                .verticalPadding(12)
                            }
                        }
                    }
                    .onTapGesture {
                        let index = selectedFaq.firstIndex(of: id)
                        withAnimation {
                            if let index {
                                selectedFaq.remove(at: index)
                            } else {
                                selectedFaq.append(id)
                            }
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    var chatComponent: some View {
        VStack(spacing: 0) {
            Spacing(height: 64)
            hText(L10n.changeAddressNoFind, style: .body)
            Spacing(height: 16)
            hButton.SmallButton(type: .primary) {
                //open chat
            } content: {
                hText(L10n.openChat, style: .body)
            }
            Spacing(height: 103)
        }
    }
}

public struct FieldInfo: Hashable, Equatable, Codable {
    let name: String
    let price: String

    init(
        name: String,
        price: String
    ) {
        self.name = name
        self.price = price
    }
}

struct MovingFlowConfirm_Previews: PreviewProvider {
    static var previews: some View {
        Localization.Locale.currentLocale = .en_SE
        return MovingFlowConfirm()
            .onAppear {
                let store: MoveFlowStore = globalPresentableStoreContainer.get()
                let quote = OctopusGraphQL.MoveIntentFragment.Quote.init(
                    premium: .init(amount: 22, currencyCode: .sek),
                    startDate: "",
                    address: .init(id: "id", street: "street", postalCode: "postal code"),
                    numberCoInsured: 2,
                    productVariant: .init(
                        perils: [],
                        typeOfContract: "SE_HOUSE",
                        documents: [
                            .init(
                                displayName: "termsAndConditions",
                                type: .termsAndConditions,
                                url: "https://www.hedvig.com"
                            )
                        ],
                        displayName: "display name",
                        insurableLimits: [
                            .init(label: "label", limit: "limit", description: "descrtiption", type: .bike),
                            .init(label: "label 2", limit: "limit 2", description: "descrtiption2", type: .deductible),
                        ],
                        highlights: [],
                        faq: [
                            .init(headline: "Headline", body: "Body"),
                            .init(headline: "Headline 2", body: "Body 2"),
                            .init(headline: "Headline 3", body: "Body 3"),
                        ]
                    )
                )
                let quote2 = OctopusGraphQL.MoveIntentFragment.Quote.init(
                    premium: .init(amount: 33, currencyCode: .sek),
                    startDate: "",
                    address: .init(id: "id2", street: "street 22", postalCode: "postal code 22"),
                    numberCoInsured: 2,
                    productVariant: .init(
                        perils: [],
                        typeOfContract: "SE_CAT_BASIC",
                        documents: [
                            .init(
                                displayName: "termsAndConditions",
                                type: .termsAndConditions,
                                url: "https://www.hedvig.com"
                            )
                        ],
                        displayName: "display name 2",
                        insurableLimits: [
                            .init(label: "label", limit: "limit", description: "descrtiption", type: .bike),
                            .init(label: "label 2", limit: "limit 2", description: "descrtiption2", type: .deductible),
                        ],
                        highlights: [],
                        faq: [
                            .init(headline: "Headline", body: "Body"),
                            .init(headline: "Headline 2", body: "Body 2"),
                            .init(headline: "Headline 3", body: "Body 3"),
                        ]
                    )
                )
                let fragment = OctopusGraphQL.MoveIntentFragment.init(
                    currentHomeAddresses: [],
                    extraBuildingTypes: [],
                    id: "id",
                    maxMovingDate: "10.10.2023.",
                    minMovingDate: "10.10.2023.",
                    suggestedNumberCoInsured: 2,
                    quotes: [quote, quote2]
                )
                let MovingFlowModel = MovingFlowModel(from: fragment)
                store.send(.setMoveIntent(with: MovingFlowModel))
            }
    }
}

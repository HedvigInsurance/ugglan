import Contracts
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
    @State var spacingFaq: CGFloat = 0
    @State var totalHeight: CGFloat = 0
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
                            VStack(spacing: 16) {
                                ForEach(movingFlowModel.quotes, id: \.id) { quote in
                                    contractInfoView(for: quote)
                                }
                                if movingFlowModel.quotes.count > 1 {
                                    noticeComponent
                                }
                                totalAmountComponent
                            }
                            .background(
                                GeometryReader { proxy in
                                    Color.clear
                                        .onAppear {
                                            spacingFaq = max(totalHeight - proxy.size.height, 0)
                                        }
                                        .onChange(of: proxy.size) { size in
                                            spacingFaq = max(totalHeight - size.height, 0)
                                        }
                                }
                            )
                            .padding(.bottom, spacingFaq)
                            VStack(spacing: 32) {
                                ForEach(movingFlowModel.quotes, id: \.id) { quote in
                                    whatIsCovered(for: quote)
                                }
                            }

                            .padding(.top, 16)
                            .id(whatIsCoveredId)
                            faqsComponent(for: movingFlowModel.faqs)
                            chatComponent

                        }
                    }
                }
            }
            .hFormAttachToBottom {
                buttonComponent(proxy: proxy)
            }
        }
        .background(
            GeometryReader { proxy in
                Color.clear
                    .onAppear {
                        totalHeight = proxy.size.height
                    }
                    .onChange(of: proxy.size) { size in
                        totalHeight = size.height
                    }
            }
        )
    }

    private func contractInfoView(for quote: Quote) -> some View {
        hSection {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(uiImage: quote.contractType?.pillowType.bgImage ?? hCoreUIAssets.bigPillowCar.image)
                        .resizable()
                        .frame(width: 48, height: 48)
                    VStack(alignment: .leading) {
                        hText(quote.exposureName ?? quote.displayName)
                        hText(L10n.changeAddressActivationDate(quote.startDate))
                            .foregroundColor(hTextColor.secondary)
                    }
                    Spacer()
                }
                Divider()
                let index = selectedInsurances.firstIndex(of: quote.id)
                let isExpanded = index != nil
                HStack(spacing: 8) {
                    hText(L10n.changeAddressDetails, style: .body)
                    Image(uiImage: hCoreUIAssets.chevronDown.image)
                        .resizable()
                        .frame(width: 16, height: 16)
                        .foregroundColor(hTextColor.tertiary)
                        .rotationEffect(isExpanded ? Angle(degrees: -180) : Angle(degrees: 0))
                    Spacer()
                    hText("\(quote.premium.formattedAmountWithoutDecimal)\(L10n.perMonth)")
                }
                if isExpanded {
                    VStack(alignment: .leading) {
                        ForEach(quote.displayItems, id: \.displayTitle) { displayItem in
                            HStack {
                                hText(displayItem.displayTitle, style: .body)
                                Spacer()
                                hText(displayItem.displayValue, style: .body)
                                    .multilineTextAlignment(.trailing)
                            }
                        }
                    }
                    .foregroundColor(hTextColor.secondary)
                }
            }
            .padding(16)
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation {
                    let index = selectedInsurances.firstIndex(of: quote.id)
                    if let index {
                        selectedInsurances.remove(at: index)
                    } else {
                        selectedInsurances.append(quote.id)
                    }
                }
            }
        }
    }

    private var noticeComponent: some View {
        hSection {
            InfoCard(
                text:
                    L10n.changeAddressOtherInsurancesInfoText,
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
                    hText(L10n.changeAddressAcceptOffer, style: .standard)
                }

                hButton.LargeButton(type: .ghost) {
                    withAnimation {
                        proxy.scrollTo(whatIsCoveredId, anchor: .top)
                    }
                } content: {
                    hText(L10n.changeAddressViewCoverage, style: .standard)
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
                    hText(quote.exposureName ?? quote.displayName, style: .standard)
                        .padding([.top, .bottom], 4)
                        .padding([.leading, .trailing], 8)

                }
                .background(
                    Squircle.default()
                        .fill(whatIsCoveredBgColorScheme)
                )
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .sectionContainerStyle(.transparent)
            Spacing(height: 16)
            hSection(quote.insurableLimits, id: \.label) { field in
                hRow {
                    hText(field.label, style: .body)
                    Spacer(minLength: 8)
                    hText(field.limit, style: .body)
                }
                .hWithoutHorizontalPadding
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
                .onTap {
                    if let url = URL(string: document.url) {
                        store.send(.navigation(action: .document(url: url, title: document.displayName)))
                    }
                }
            }
            Spacing(height: 40)
        }
    }

    private let whatIsCoveredBgColorScheme: some hColor = hColorScheme.init(
        light: hBlueColor.blue100,
        dark: hBlueColor.blue900
    )

    @ViewBuilder
    func faqsComponent(for faqs: [FAQ]) -> some View {
        if !faqs.isEmpty {
            hSection {
                VStack(alignment: .leading, spacing: 0) {
                    hText(L10n.changeAddressQa)
                    hText(L10n.changeAddressFaqSubtitle).foregroundColor(hTextColor.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .sectionContainerStyle(.transparent)
            VStack(spacing: 4) {
                ForEach(faqs, id: \.title) { faq in
                    let id = "\(faq.title)"
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
                                    hText(description, style: .standardSmall).foregroundColor(hTextColor.secondary)

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
                store.send(.navigation(action: .goToFreeTextChat))
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
        Localization.Locale.currentLocale = .nb_NO
        return MovingFlowConfirm()
            .onAppear {
                let store: MoveFlowStore = globalPresentableStoreContainer.get()
                let quote = OctopusGraphQL.MoveIntentFragment.Quote.init(
                    premium: .init(amount: 22, currencyCode: .sek),
                    startDate: "",
                    productVariant: .init(
                        perils: [],
                        typeOfContract: "SE_HOUSE",
                        termsVersion: "Id",
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
                        ]
                    ),
                    displayItems: []
                )
                let quote2 = OctopusGraphQL.MoveIntentFragment.Quote.init(
                    premium: .init(amount: 33, currencyCode: .sek),
                    startDate: "",
                    productVariant: .init(
                        perils: [],
                        typeOfContract: "SE_CAT_BASIC",
                        termsVersion: "Id",
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
                        ]
                    ),
                    displayItems: []
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

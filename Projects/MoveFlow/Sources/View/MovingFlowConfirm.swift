import SwiftUI
import hCore
import hCoreUI

struct MovingFlowConfirm: View {
    @PresentableStore var store: MoveFlowStore
    @State var isMultipleOffer = true
    @State var selectedInsurances: [String] = [""]

    var body: some View {
        hForm {
            VStack(spacing: 16) {
                if isMultipleOffer {
                    showCardComponent(
                        insuranceName: "Hemförsäkring",
                        price: "179 kr/mån"
                    )
                    showCardComponent(
                        insuranceName: "Olycksfallsförsäkring",
                        price: "99 kr/mån"
                    )
                    noticeComponent
                } else {
                    showCardComponent(
                        insuranceName: "Hemförsäkring",
                        price: "179 kr/mån"
                    )
                }
                overviewComponent
                if isMultipleOffer {
                    whatIsCovered(
                        insuranceName: "Hemförsäkring",
                        fields: [
                            FieldInfo(
                                name: "Försäkrat belopp",
                                price: "1 000 000 kr"
                            ),
                            FieldInfo(
                                name: "Självrisk",
                                price: "1 500 kr"
                            ),
                            FieldInfo(
                                name: "Reseskydd",
                                price: "45 dagar"
                            ),
                        ]
                    )

                    whatIsCovered(
                        insuranceName: "Olycksfallsförsäkring",
                        fields: [
                            FieldInfo(
                                name: "Försäkrat belopp",
                                price: "1 000 000 kr"
                            ),
                            FieldInfo(
                                name: "Självrisk",
                                price: "1 500 kr"
                            ),
                        ]
                    )
                } else {
                    whatIsCovered(
                        insuranceName: "Hemförsäkring",
                        fields: [
                            FieldInfo(
                                name: "Försäkrat belopp",
                                price: "1 000 000 kr"
                            ),
                            FieldInfo(
                                name: "Självrisk",
                                price: "1 500 kr"
                            ),
                            FieldInfo(
                                name: "Reseskydd",
                                price: "45 dagar"
                            ),
                        ]
                    )
                }
                questionAnswerComponent
                chatComponent
            }
        }
        .hFormTitle(.standard, .title3, L10n.changeAddressAcceptOffer)
    }

    @ViewBuilder
    func returnMainContent(coverageName: String) -> some View {
        HStack {
            Image(uiImage: hCoreUIAssets.plusSmall.image)
            hText(coverageName, style: .title3)
            Spacer()
            Image(uiImage: hCoreUIAssets.plusSmall.image)
        }
    }

    func returnMiddleComponent(insuranceName: String) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            hText(insuranceName, style: .body)
                .foregroundColor(hTextColorNew.primary)
            HStack {
                hText(L10n.changeAddressActivationDate("02.12.24"), style: .body)
                Image(uiImage: hCoreUIAssets.infoSmall.image)
                    .resizable()
                    .frame(width: 14, height: 14)
            }
            .foregroundColor(hTextColorNew.secondary)
        }
    }

    @ViewBuilder
    func returnBottomComponent(insuranceName: String, price: String) -> some View {
        HStack {
            hText(L10n.changeAddressDetails, style: .body)
            Image(uiImage: hCoreUIAssets.chevronDown.image)
                .foregroundColor(hTextColorNew.tertiary)
            Spacer()
            hText(price, style: .body)
        }
        .onTapGesture {
            if selectedInsurances.contains(insuranceName) {
                let index = selectedInsurances.firstIndex(of: insuranceName)
                selectedInsurances.remove(at: index ?? 10)
            } else {
                selectedInsurances.append(insuranceName)
            }
        }

        if selectedInsurances.contains(insuranceName) {
            VStack(alignment: .leading) {
                HStack {
                    hText("Bostadstyp", style: .body)
                    Spacer()
                    hText("Bostadsrätt", style: .body)
                }

                HStack {
                    hText("Adress", style: .body)
                    Spacer()
                    hText("Bellmansgatan 19A", style: .body)
                }

                HStack {
                    hText("Postkod", style: .body)
                    Spacer()
                    hText("11847", style: .body)
                }

                HStack {
                    hText("Postkod", style: .body)
                    Spacer()
                    hText("11847", style: .body)
                }

                HStack {
                    hText("Postkod", style: .body)
                    Spacer()
                    hText("11847", style: .body)
                }

                hText("Dokument", style: .body)
                    .foregroundColor(hLabelColor.primary)
                    .padding(.vertical, 16)

                hText("Försäkringsvillkor", style: .body)
                hText("Försäkringsinformation", style: .body)
                hText("Produktfaktablad", style: .body)
            }
            .padding(.vertical, 16)
            .foregroundColor(hTextColorNew.secondary)

            hButton.SmallButtonText {
                //                store.send(.navigationActionMovingFlow(action: .openAddressFillScreen))
            } content: {
                hText("Ändra", style: .body)
            }

        }
    }

    @ViewBuilder
    func showCardComponent(insuranceName: String, price: String) -> some View {
        CardComponent(
            mainContent: Image(uiImage: hCoreUIAssets.pillowHome.image)
                .resizable()
                .frame(width: 49, height: 49),
            middleContent: returnMiddleComponent(insuranceName: insuranceName),
            bottomComponent: {
                returnBottomComponent(
                    insuranceName: insuranceName,
                    price: price
                )
            }
        )
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    var noticeComponent: some View {
        InfoCard(
            text:
                L10n.changeAddressAccidentNotice,
            type: .info
        )
        .padding(.bottom, 16)
    }

    @ViewBuilder
    var overviewComponent: some View {
        HStack {
            hText(L10n.changeAddressTotal, style: .body)
            Spacer()
            hText("278 kr/mån", style: .body)
        }
        .padding([.leading, .trailing], 16)
        .padding(.bottom, 16)

        hButton.LargeButtonPrimary {
            //            store.send(.navigationActionMovingFlow(action: .openFailureScreen))
        } content: {
            hText(L10n.changeAddressAcceptOffer, style: .body)
        }
        .padding([.leading, .trailing], 16)
        .padding(.bottom, 22)

        hText(L10n.changeAddressIncluded, style: .body)
            .padding(.bottom, 98)
    }

    @ViewBuilder
    func whatIsCovered(insuranceName: String, fields: [FieldInfo]) -> some View {
        VStack {
            hText(insuranceName, style: .footnote)
                .padding([.top, .bottom], 4)
                .padding([.leading, .trailing], 8)

        }
        .background(
            Squircle.default()
                .fill(hBlueColorNew.blue100)
        )
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding([.leading, .trailing], 16)

        hSection(fields, id: \.self) { field in
            hRow {
                hText(field.name, style: .body)
                Spacer()
                hText(field.price, style: .body)
                Image(uiImage: hCoreUIAssets.infoSmall.image)
                    .resizable()
                    .frame(width: 14, height: 14)
                    .foregroundColor(hGrayscaleColorNew.greyScale700)
            }
        }
        .sectionContainerStyle(.transparent)

        VStack {
            hText(L10n.changeAddressCovered, style: .footnote)
                .padding([.top, .bottom], 4)
                .padding([.leading, .trailing], 8)

        }
        .background(
            Squircle.default()
                .fill(hBlueColorNew.blue100)
        )
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding([.leading, .trailing], 16)

        VStack {
            TextBoxComponent(
                onSelected: {
                    // open info about
                },
                mainContent: returnMainContent(coverageName: "Eldsvåda")
            )

            TextBoxComponent(
                onSelected: {
                    // open info about
                },
                mainContent: returnMainContent(coverageName: "Vattenskada")
            )

            TextBoxComponent(
                onSelected: {
                    // open info about
                },
                mainContent: returnMainContent(coverageName: "Oväder")
            )
        }
        .padding([.leading, .trailing], 16)
        .padding(.bottom, 80)
    }

    @ViewBuilder
    var questionAnswerComponent: some View {
        hText(L10n.changeAddressQa, style: .title3)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 16)
        TextBoxComponent(
            mainContent: answerMainComponent
        )
        .padding([.leading, .trailing], 16)
        .padding(.bottom, 80)
    }

    @ViewBuilder
    var answerMainComponent: some View {
        HStack {
            hText("Vad ingår i en hemförsäkring?", style: .body)
            Spacer()
            Image(uiImage: hCoreUIAssets.plusSmall.image)
        }
    }

    @ViewBuilder
    var chatComponent: some View {
        hText(L10n.changeAddressNoFind, style: .body)
        hButton.SmallButtonFilled {
            //open chat
        } content: {
            hText(L10n.openChat, style: .body)
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
        MovingFlowConfirm()
    }
}

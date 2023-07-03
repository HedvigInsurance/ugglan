import SwiftUI
import hCore
import hCoreUI

struct MovingFlowConfirm: View {
    @PresentableStore var store: ContractStore
    @State var isMultipleOffer = true
    @State var selectedInsurances: [String] = [""]

    var body: some View {
        hForm {

            hTextNew(L10n.changeAddressAcceptOffer, style: .title3)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 50)

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
                overviewComponent()
            } else {
                showCardComponent(
                    insuranceName: "Hemförsäkring",
                    price: "179 kr/mån"
                )
                overviewComponent()
            }
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
        .hUseNewStyle
    }

    @ViewBuilder
    func returnMainContent(coverageName: String) -> some View {
        HStack {
            Image(uiImage: hCoreUIAssets.plusIcon.image)
            hTextNew(coverageName, style: .title3)
            Spacer()
            Image(uiImage: hCoreUIAssets.plusIcon.image)
        }
    }

    func returnSubComponent() -> some View {
        HStack {
            hTextNew(L10n.changeAddressActivationDate("02.12.24"), style: .body)
            Image(uiImage: hCoreUIAssets.infoSmall.image)
                .resizable()
                .frame(width: 14, height: 14)
        }
        .foregroundColor(hGrayscaleColorNew.greyScale700)
    }

    @ViewBuilder
    func returnBottomComponent(insuranceName: String, price: String) -> some View {
        HStack {
            hTextNew(L10n.changeAddressDetails, style: .body)
            Image(uiImage: hCoreUIAssets.chevronDown.image)
                .foregroundColor(hLabelColorNew.tertiary)
            Spacer()
            hTextNew(price, style: .body)
        }
        .padding([.leading, .trailing], 16)
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
                    hTextNew("Bostadstyp", style: .body)
                    Spacer()
                    hTextNew("Bostadsrätt", style: .body)
                }

                HStack {
                    hTextNew("Adress", style: .body)
                    Spacer()
                    hTextNew("Bellmansgatan 19A", style: .body)
                }

                HStack {
                    hTextNew("Postkod", style: .body)
                    Spacer()
                    hTextNew("11847", style: .body)
                }

                HStack {
                    hTextNew("Postkod", style: .body)
                    Spacer()
                    hTextNew("11847", style: .body)
                }

                HStack {
                    hTextNew("Postkod", style: .body)
                    Spacer()
                    hTextNew("11847", style: .body)
                }

                hText("Dokument", style: .body)
                    .foregroundColor(hLabelColor.primary)
                    .padding([.top, .bottom], 16)

                hTextNew("Försäkringsvillkor", style: .body)
                hTextNew("Försäkringsinformation", style: .body)
                hTextNew("Produktfaktablad", style: .body)
            }
            .padding([.leading, .trailing, .top], 16)
            .foregroundColor(hGrayscaleColorNew.greyScale700)
        }
    }

    @ViewBuilder
    func showCardComponent(insuranceName: String, price: String) -> some View {
        CardComponent(
            mainContent: Image(uiImage: hCoreUIAssets.pillowHome.image)
                .resizable()
                .frame(width: 49, height: 49),
            //                .foregroundColor(hGrayscaleColorNew.greyScale900),
            topTitle: insuranceName,
            //            topSubTitle: returnSubComponent(),
            bottomComponent: {
                returnBottomComponent(
                    insuranceName: insuranceName,
                    price: price
                )
            }
        )
        //        .cardComponentOptions([.hideArrow])
        //        .padding([.leading, .trailing], 16)
        //        .padding(.bottom, 8)
    }

    @ViewBuilder
    var noticeComponent: some View {
        InfoCard(
            text:
                L10n.changeAddressAccidentNotice
        )
        .padding(.bottom, 16)
    }

    @ViewBuilder
    func overviewComponent() -> some View {
        HStack {
            hTextNew(L10n.changeAddressTotal, style: .body)
            Spacer()
            hTextNew("278 kr/mån", style: .body)
        }
        .padding([.leading, .trailing], 16)
        .padding(.bottom, 16)

        hButton.LargeButtonFilled {
            store.send(.navigationActionMovingFlow(action: .openFailureScreen))
        } content: {
            hTextNew(L10n.changeAddressAcceptOffer, style: .body)
        }
        .padding([.leading, .trailing], 16)
        .padding(.bottom, 22)

        hTextNew(L10n.changeAddressIncluded, style: .body)
            .padding(.bottom, 98)
    }

    @ViewBuilder
    func whatIsCovered(insuranceName: String, fields: [FieldInfo]) -> some View {
        VStack {
            hTextNew(insuranceName, style: .footnote)
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
                hTextNew(field.name, style: .body)
                Spacer()
                hTextNew(field.price, style: .body)
                Image(uiImage: hCoreUIAssets.infoSmall.image)
                    .resizable()
                    .frame(width: 14, height: 14)
                    .foregroundColor(hGrayscaleColorNew.greyScale700)
            }
        }
        .sectionContainerStyle(.transparent)

        VStack {
            hTextNew(L10n.changeAddressCovered, style: .footnote)
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
        hTextNew(L10n.changeAddressQa, style: .title3)
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
            hTextNew("Vad ingår i en hemförsäkring?", style: .body)
            Spacer()
            Image(uiImage: hCoreUIAssets.plusIcon.image)
        }
    }

    @ViewBuilder
    var chatComponent: some View {
        hTextNew(L10n.changeAddressNoFind, style: .body)
        hButton.SmallButtonFilled {
            //open chat
        } content: {
            hTextNew(L10n.openChat, style: .body)
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

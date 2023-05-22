import SwiftUI
import hCore
import hCoreUI

struct MovingFlowConfirm: View {
    @PresentableStore var store: ContractStore
    @State var isMultipleOffer = true
    @State var selectedInsurances: [String] = [""]

    var body: some View {
        hFormNew {

            hText(L10n.changeAddressAcceptOffer, style: .title1)
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
    }

    @ViewBuilder
    func returnMainContent(coverageName: String) -> some View {
        HStack {
            Image(uiImage: hCoreUIAssets.plusIcon.image)
            hText(coverageName, style: .title1)
            Spacer()
            Image(uiImage: hCoreUIAssets.plusIcon.image)
        }
    }

    func returnSubComponent() -> some View {
        HStack {
            hText("Aktiveras 02.12.24", style: .body)
            Image(uiImage: hCoreUIAssets.infoSmall.image)
                .resizable()
                .frame(width: 14, height: 14)
        }
        .foregroundColor(hGrayscaleColorNew.greyScale700)
    }

    @ViewBuilder
    func returnBottomComponent(insuranceName: String, price: String) -> some View {
        HStack {
            hText("Detaljer", style: .body)
            Image(uiImage: hCoreUIAssets.chevronDown.image)
                .foregroundColor(hGrayscaleColorNew.greyScale500)
            Spacer()
            hText(price, style: .body)
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
                    hText("Bostadstyp")
                    Spacer()
                    hText("Bostadsrätt")
                }

                HStack {
                    hText("Adress")
                    Spacer()
                    hText("Bellmansgatan 19A")
                }

                HStack {
                    hText("Postkod")
                    Spacer()
                    hText("11847")
                }

                HStack {
                    hText("Postkod")
                    Spacer()
                    hText("11847")
                }

                HStack {
                    hText("Postkod")
                    Spacer()
                    hText("11847")
                }

                hText("Dokument", style: .body)
                    .foregroundColor(hLabelColor.primary)
                    .padding([.top, .bottom], 16)

                hText("Försäkringsvillkor")
                hText("Försäkringsinformation")
                hText("Produktfaktablad")
            }
            .padding([.leading, .trailing, .top], 16)
            .foregroundColor(hGrayscaleColorNew.greyScale700)
        }
    }

    @ViewBuilder
    func showCardComponent(insuranceName: String, price: String) -> some View {
        CardComponent(
            mainContent: Image(uiImage: hCoreUIAssets.pillowHome.image).resizable()
                .frame(width: 49, height: 49)
                .foregroundColor(hGrayscaleColorNew.greyScale900),
            topTitle: insuranceName,
            topSubTitle: returnSubComponent(),
            bottomComponent: returnBottomComponent(
                insuranceName: insuranceName,
                price: price
            ),
            isNew: true
        )
        .cardComponentOptions([.hideArrow])
        .padding([.leading, .trailing], 16)
        .padding(.bottom, 8)
    }

    @ViewBuilder
    var noticeComponent: some View {
        NoticeComponent(
            text:
                "Din Olycksfallsförsäkring påverkas när du byter till en ny adress. Ditt pris kan ha ändrats men du behåller samma skydd som tidigare."
        )
        .padding([.leading, .trailing], 16)
        .padding(.bottom, 16)
    }

    @ViewBuilder
    func overviewComponent() -> some View {
        HStack {
            hText("Totalt", style: .body)
            Spacer()
            hText("278 kr/mån", style: .body)
        }
        .padding([.leading, .trailing], 16)
        .padding(.bottom, 16)

        hButton.LargeButtonFilled {
            store.send(.navigationActionMovingFlow(action: .openFailureScreen))
        } content: {
            hText("Bekräfta ändringar", style: .body)
        }
        .padding([.leading, .trailing], 16)
        .padding(.bottom, 22)

        hText("Se vad som ingår", style: .body)
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
                .fill(hTintColorNew.blue100)
        )
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding([.leading, .trailing], 16)

        hSection(fields, id: \.self) { field in
            hRow {
                hText(field.name)
                Spacer()
                hText(field.price)
                Image(uiImage: hCoreUIAssets.infoSmall.image)
                    .resizable()
                    .frame(width: 14, height: 14)
                    .foregroundColor(hGrayscaleColorNew.greyScale700)
            }
        }
        .sectionContainerStyle(.transparent)

        VStack {
            hText("Vad som täcks", style: .footnote)
                .padding([.top, .bottom], 4)
                .padding([.leading, .trailing], 8)

        }
        .background(
            Squircle.default()
                .fill(hTintColorNew.blue100)
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
        hText("Frågor och svar", style: .title1)
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
            Image(uiImage: hCoreUIAssets.plusIcon.image)
        }
    }

    @ViewBuilder
    var chatComponent: some View {
        hText("Hittar du inte det du söker?", style: .body)
        hButton.SmallButtonFilled {
            //open chat
        } content: {
            hText(L10n.openChat)
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

import SwiftUI
import hCore
import hCoreUI

struct MovingFlowConfirm: View {
    @State var showDetails = false

    var body: some View {
        hFormNew {

            hText("Bekräfta ändringar", style: .title1)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 50)

            overviewComponent
            infoComponent
            whatIsCovered
            questionAnswerComponent
            chatComponent
        }
    }

    @ViewBuilder
    func returnMainContent() -> some View {
        HStack {
            Image(uiImage: hCoreUIAssets.plusIcon.image)
            hText("Eldsvåda", style: .title1)
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
    func returnBottomComponent() -> some View {
        HStack {
            hText("Detaljer", style: .body)
            Image(uiImage: hCoreUIAssets.chevronDown.image)
                .foregroundColor(hGrayscaleColorNew.greyScale500)
            Spacer()
            hText("179 kr/mån", style: .body)
        }
        .padding([.leading, .trailing], 16)
        .onTapGesture {
            if showDetails {
                showDetails = false
            } else {
                showDetails = true
            }
        }

        if showDetails {
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
                //                .padding([.leading, .trailing, .top], 16)

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
    var overviewComponent: some View {
        CardComponent(
            mainContent: Image(uiImage: hCoreUIAssets.pillowHome.image).resizable()
                .frame(width: 49, height: 49),
            topTitle: "Hemförsäkring",
            topSubTitle: returnSubComponent(),
            bottomComponent: returnBottomComponent,
            isNew: true
        )
        .cardComponentOptions([.hideArrow])
        .padding([.leading, .trailing], 16)
        .padding(.bottom, 8)

        NoticeComponent(
            text:
                "Din Olycksfallsförsäkring påverkas när du byter till en ny adress. Ditt pris kan ha ändrats men du behåller samma skydd som tidigare."
        )
        .padding([.leading, .trailing], 16)
        .padding(.bottom, 16)

        HStack {
            hText("Totalt", style: .body)
            Spacer()
            hText("278 kr/mån", style: .body)
        }
        .padding([.leading, .trailing], 16)
        .padding(.bottom, 16)

        hButton.LargeButtonFilled {
            //action
        } content: {
            hText("Bekräfta ändringar", style: .body)
        }
        .padding([.leading, .trailing], 16)
        .padding(.bottom, 22)

        hText("Se vad som ingår", style: .body)
            .padding(.bottom, 98)
    }

    @ViewBuilder
    var infoComponent: some View {
        VStack {
            hText("Hemförsäkring", style: .footnote)
                .padding([.top, .bottom], 4)
                .padding([.leading, .trailing], 8)

        }
        .background(
            Squircle.default()
                .fill(hTintColorNew.blue100)
        )
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding([.leading, .trailing], 16)

        hSection {
            hRow {
                hText("Försäkrat belopp")
                Spacer()
                hText("1 000 000 kr")
                Image(uiImage: hCoreUIAssets.infoSmall.image)
                    .resizable()
                    .frame(width: 14, height: 14)
                    .foregroundColor(hGrayscaleColorNew.greyScale500)
            }
            hRow {
                hText("Självrisk")
                Spacer()
                hText("1 500 kr")
                Image(uiImage: hCoreUIAssets.infoSmall.image)
                    .resizable()
                    .frame(width: 14, height: 14)
                    .foregroundColor(hGrayscaleColorNew.greyScale500)
            }
            hRow {
                hText("Reseskydd")
                Spacer()
                hText("45 dagar")
                Image(uiImage: hCoreUIAssets.infoSmall.image)
                    .resizable()
                    .frame(width: 14, height: 14)
                    .foregroundColor(hGrayscaleColorNew.greyScale500)
            }
        }
        .sectionContainerStyle(.transparent)
    }

    @ViewBuilder
    var whatIsCovered: some View {
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

        TextBoxComponent(
            onSelected: {
                // open info about
            },
            mainContent: returnMainContent()
        )
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
            hText("Öppna chatten")
        }
    }
}

struct MovingFlowConfirm_Previews: PreviewProvider {
    static var previews: some View {
        MovingFlowConfirm()
    }
}

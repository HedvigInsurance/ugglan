import SwiftUI
import hCore
import hCoreUI

enum PillColor {
    case green
    case yellow
    case blue
    case purple
    case pink
}

struct HelpCenterPill: View {
    private let title: String
    private let color: PillColor

    public init(
        title: String,
        color: PillColor
    ) {
        self.title = title
        self.color = color
    }

    @hColorBuilder
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                hText(title)
                    .foregroundColor(hTextColor.primaryTranslucent)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Squircle.default()
                    .fill(pillBackgroundColor)
            )
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    @hColorBuilder
    var pillBackgroundColor: some hColor {
        switch color {
        case .blue:
            hHighlightColor.blueFillOne
        case .green:
            hSignalColor.greenFill
        case .yellow:
            hHighlightColor.yellowFillOne
        case .purple:
            hHighlightColor.purpleFillOne
        case .pink:
            hHighlightColor.pinkFillOne
        }
    }
}

enum QuestionType {
    case commonQuestions
    case allQuestions
    case relatedQuestions
}

struct QuestionsItems: View {
    let questions: [Question]
    let questionType: QuestionType
    @PresentableStore var store: HomeStore

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            switch questionType {
            case .commonQuestions:
                HelpCenterPill(title: "Common questions", color: .blue)
            case .allQuestions:
                HelpCenterPill(title: "All questions", color: .purple)
            case .relatedQuestions:
                HelpCenterPill(title: "Related questions", color: .pink)
            }
            VStack(alignment: .leading, spacing: 4) {
                hSection(questions, id: \.self) { item in
                    hRow {
                        hText(item.question)
                            .fixedSize()
                    }
                    .withChevronAccessory
                    .hWithoutHorizontalPadding
                    .onTapGesture {
                        store.send(.openHelpCenterQuestionView(question: item))
                    }
                }
                .withoutHorizontalPadding
                .sectionContainerStyle(.transparent)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct SupportView: View {
    @PresentableStore var store: HomeStore

    var body: some View {
        hSection {
            VStack(spacing: 0) {
                hText("Still need help?")
                    .foregroundColor(hTextColor.primaryTranslucent)
                Group {
                    hText("We're here Mon-Fri 08-16")
                    hText("Sat-Sun 08-14")
                }
                .foregroundColor(hTextColor.secondaryTranslucent)

                hButton.MediumButton(type: .primary) {
                    store.send(.openFreeTextChat)
                } content: {
                    hText("Chat with us")
                }
                .padding(.top, 16)
                .fixedSize()
            }
            .padding(.vertical, 32)
        }
        .withoutHorizontalPadding
    }
}

#Preview{
    SupportView()
}

import SwiftUI
import hCore
import hCoreUI

enum QuestionType: String {
    case commonQuestions
    case allQuestions
    case relatedQuestions
    case searchQuestions

    var title: String {
        switch self {
        case .commonQuestions:
            return L10n.hcCommonQuestionsTitle
        case .allQuestions:
            return L10n.hcAllQuestionTitle
        case .relatedQuestions:
            return L10n.hcRelatedQuestionsTitle
        case .searchQuestions:
            return L10n.hcQuestionsTitle
        }
    }
}

struct QuestionsItems: View {
    let questions: [FAQModel]
    let questionType: QuestionType
    let source: HelpViewSource
    @EnvironmentObject var router: Router

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            switch questionType {
            case .commonQuestions, .searchQuestions:
                HelpCenterPill(title: questionType.title, color: .blue)
            case .allQuestions:
                HelpCenterPill(title: questionType.title, color: .purple)
            case .relatedQuestions:
                HelpCenterPill(title: questionType.title, color: .pink)
            }
            VStack(alignment: .leading, spacing: .padding4) {
                hSection(questions, id: \.self) { item in
                    hRow {
                        hText(item.question)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer()
                    }
                    .withChevronAccessory
                    .onTap {
                        let attributes: [String: String] = [
                            "question": item.question,
                            "answer": item.answer,
                            "sourcePath": source.title,
                            "questionType": questionType.rawValue,
                        ]
                        log.info("question clicked", error: nil, attributes: ["helpCenter": attributes])
                        router.push(item)
                    }
                    .hWithoutHorizontalPadding([.row, .divider])
                }
                .hWithoutHorizontalPadding([.section])
                .sectionContainerStyle(.transparent)
                .padding(.leading, 2)
            }
        }
    }
}

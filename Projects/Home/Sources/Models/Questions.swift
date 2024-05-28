import Foundation
import hCore

protocol QuestionProtocol {
    associatedtype ObjectType = Self
    static func all() -> [ObjectType]
    static func common() -> [ObjectType]
    static func others() -> [ObjectType]
    func asQuestion() -> Question
}

extension Sequence where Iterator.Element: QuestionProtocol {
    func asQuestions() -> [Question] {
        return map({ $0.asQuestion() })
    }
}

enum PaymentsQuestions: CaseIterable {
    case q1
    case q2
    case q3
    case q4
    case q5
    case q6
    case q7
    case q8
    case q9
    case q10
    case q11
    case q12
    case q13
    case q14

    var question: Question {
        switch self {
        case .q1:
            return .init(
                question: L10n.hcPaymentsQ01,
                questionEn: L10n.hcPaymentsQ01_en,
                answer: L10n.hcPaymentsA01,
                topicType: .payments
            )
        case .q2:
            return .init(
                question: L10n.hcPaymentsQ02,
                questionEn: L10n.hcPaymentsQ02_en,
                answer: L10n.hcPaymentsA02,
                topicType: .payments
            )
        case .q3:
            return .init(
                question: L10n.hcPaymentsQ03,
                questionEn: L10n.hcPaymentsQ03_en,
                answer: L10n.hcPaymentsA03,
                topicType: .payments
            )
        case .q4:
            return .init(
                question: L10n.hcPaymentsQ04,
                questionEn: L10n.hcPaymentsQ04_en,
                answer: L10n.hcPaymentsA04,
                topicType: .payments
            )
        case .q5:
            return .init(
                question: L10n.hcPaymentsQ05,
                questionEn: L10n.hcPaymentsQ05_en,
                answer: L10n.hcPaymentsA05,
                topicType: .payments
            )
        case .q6:
            return .init(
                question: L10n.hcPaymentsQ06,
                questionEn: L10n.hcPaymentsQ06_en,
                answer: L10n.hcPaymentsA06,
                topicType: .payments
            )
        case .q7:
            return .init(
                question: L10n.hcPaymentsQ07,
                questionEn: L10n.hcPaymentsQ07_en,
                answer: L10n.hcPaymentsA07,
                topicType: .payments
            )
        case .q8:
            return .init(
                question: L10n.hcPaymentsQ08,
                questionEn: L10n.hcPaymentsQ08_en,
                answer: L10n.hcPaymentsA08,
                topicType: .payments
            )
        case .q9:
            return .init(
                question: L10n.hcPaymentsQ09,
                questionEn: L10n.hcPaymentsQ09_en,
                answer: L10n.hcPaymentsA09,
                topicType: .payments
            )
        case .q10:
            return .init(
                question: L10n.hcPaymentsQ10,
                questionEn: L10n.hcPaymentsQ10_en,
                answer: L10n.hcPaymentsA10,
                topicType: .payments
            )
        case .q11:
            return .init(
                question: L10n.hcPaymentsQ11,
                questionEn: L10n.hcPaymentsQ11_en,
                answer: L10n.hcPaymentsA11,
                topicType: .payments
            )
        case .q12:
            return .init(
                question: L10n.hcPaymentsQ12,
                questionEn: L10n.hcPaymentsQ12_en,
                answer: L10n.hcPaymentsA12,
                topicType: .payments
            )
        case .q13:
            return .init(
                question: L10n.hcPaymentsQ13,
                questionEn: L10n.hcPaymentsQ13_en,
                answer: L10n.hcPaymentsA13,
                topicType: .payments
            )
        case .q14:
            return .init(
                question: L10n.hcPaymentsQ14,
                questionEn: L10n.hcPaymentsQ14_en,
                answer: L10n.hcPaymentsA14,
                topicType: .payments
            )
        }
    }
}

extension PaymentsQuestions: QuestionProtocol {
    static func all() -> [PaymentsQuestions] {
        return PaymentsQuestions.allCases
    }

    static func common() -> [PaymentsQuestions] {
        return [.q1, .q2, .q3]
    }

    static func others() -> [PaymentsQuestions] {
        let allQuestions = all()
        let commmonQuestions = common()
        return allQuestions.filter({ !commmonQuestions.contains($0) })
    }
    func asQuestion() -> Question {
        return question
    }
}

enum ClaimsQuestions: CaseIterable {
    case q1
    case q2
    case q3
    case q4
    case q5
    case q6
    case q7
    case q8
    case q9
    case q10
    case q11
    case q12

    var question: Question {
        switch self {
        case .q1:
            return .init(
                question: L10n.hcClaimsQ01,
                questionEn: L10n.hcClaimsQ01_en,
                answer: L10n.hcClaimsA01,
                topicType: .claims
            )
        case .q2:
            return .init(
                question: L10n.hcClaimsQ02,
                questionEn: L10n.hcClaimsQ02_en,
                answer: L10n.hcClaimsA02,
                topicType: .claims
            )
        case .q3:
            return .init(
                question: L10n.hcClaimsQ03,
                questionEn: L10n.hcClaimsQ03_en,
                answer: L10n.hcClaimsA03,
                topicType: .claims
            )
        case .q4:
            return .init(
                question: L10n.hcClaimsQ04,
                questionEn: L10n.hcClaimsQ04_en,
                answer: L10n.hcClaimsA04,
                topicType: .claims
            )

        case .q5:
            return .init(
                question: L10n.hcClaimsQ05,
                questionEn: L10n.hcClaimsQ05_en,
                answer: L10n.hcClaimsA05,
                topicType: .claims
            )
        case .q6:
            return .init(
                question: L10n.hcClaimsQ06,
                questionEn: L10n.hcClaimsQ06_en,
                answer: L10n.hcClaimsA06,
                topicType: .claims
            )
        case .q7:
            return .init(
                question: L10n.hcClaimsQ07,
                questionEn: L10n.hcClaimsQ07_en,
                answer: L10n.hcClaimsA07,
                topicType: .claims
            )
        case .q8:
            return .init(
                question: L10n.hcClaimsQ08,
                questionEn: L10n.hcClaimsQ08_en,
                answer: L10n.hcClaimsA08,
                topicType: .claims
            )
        case .q9:
            return .init(
                question: L10n.hcClaimsQ09,
                questionEn: L10n.hcClaimsQ09_en,
                answer: L10n.hcClaimsA09,
                topicType: .claims
            )
        case .q10:
            return .init(
                question: L10n.hcClaimsQ10,
                questionEn: L10n.hcClaimsQ10_en,
                answer: L10n.hcClaimsA10,
                topicType: .claims
            )
        case .q11:
            return .init(
                question: L10n.hcClaimsQ11,
                questionEn: L10n.hcClaimsQ11_en,
                answer: L10n.hcClaimsA11,
                topicType: .claims
            )
        case .q12:
            return .init(
                question: L10n.hcClaimsQ12,
                questionEn: L10n.hcClaimsQ12_en,
                answer: L10n.hcClaimsA12,
                topicType: .claims
            )
        }
    }
}

extension ClaimsQuestions: QuestionProtocol {
    static func all() -> [ClaimsQuestions] {
        return ClaimsQuestions.allCases
    }

    static func common() -> [ClaimsQuestions] {
        return [.q1, .q2, .q3]
    }

    static func others() -> [ClaimsQuestions] {
        let allQuestions = all()
        let commmonQuestions = common()
        return allQuestions.filter({ !commmonQuestions.contains($0) })
    }
    func asQuestion() -> Question {
        return question
    }
}

enum CoverageQuestions: CaseIterable {
    case q1
    case q2
    case q3
    case q4
    case q5
    case q6
    case q7
    case q8
    case q9
    case q10
    case q11
    case q12
    case q13
    case q14
    case q15
    case q17
    case q18
    case q19
    case q20
    case q21
    case q22
    var question: Question {
        switch self {
        case .q1:
            return .init(
                question: L10n.hcCoverageQ01,
                questionEn: L10n.hcCoverageQ01_en,
                answer: L10n.hcCoverageA01,
                topicType: .coverage
            )

        case .q2:
            return .init(
                question: L10n.hcCoverageQ02,
                questionEn: L10n.hcCoverageQ02_en,
                answer: L10n.hcCoverageA02,
                topicType: .coverage
            )
        case .q3:
            return .init(
                question: L10n.hcCoverageQ03,
                questionEn: L10n.hcCoverageQ03_en,
                answer: L10n.hcCoverageA03,
                topicType: .coverage
            )
        case .q4:
            return .init(
                question: L10n.hcCoverageQ04,
                questionEn: L10n.hcCoverageQ04_en,
                answer: L10n.hcCoverageA04,
                topicType: .coverage
            )
        case .q5:
            return .init(
                question: L10n.hcCoverageQ05,
                questionEn: L10n.hcCoverageQ05_en,
                answer: L10n.hcCoverageA05,
                topicType: .coverage
            )
        case .q6:
            return .init(
                question: L10n.hcCoverageQ06,
                questionEn: L10n.hcCoverageQ06_en,
                answer: L10n.hcCoverageA06,
                topicType: .coverage
            )
        case .q7:
            return .init(
                question: L10n.hcCoverageQ07,
                questionEn: L10n.hcCoverageQ07_en,
                answer: L10n.hcCoverageA07,
                topicType: .coverage
            )
        case .q8:
            return .init(
                question: L10n.hcCoverageQ08,
                questionEn: L10n.hcCoverageQ08_en,
                answer: L10n.hcCoverageA08,
                topicType: .coverage
            )
        case .q9:
            return .init(
                question: L10n.hcCoverageQ09,
                questionEn: L10n.hcCoverageQ09_en,
                answer: L10n.hcCoverageA09,
                topicType: .coverage
            )
        case .q10:
            return .init(
                question: L10n.hcCoverageQ10,
                questionEn: L10n.hcCoverageQ10_en,
                answer: L10n.hcCoverageA10,
                topicType: .coverage
            )
        case .q11:
            return .init(
                question: L10n.hcCoverageQ11,
                questionEn: L10n.hcCoverageQ11_en,
                answer: L10n.hcCoverageA11,
                topicType: .coverage
            )
        case .q12:
            return .init(
                question: L10n.hcCoverageQ12,
                questionEn: L10n.hcCoverageQ12_en,
                answer: L10n.hcCoverageA12,
                topicType: .coverage
            )
        case .q13:
            return .init(
                question: L10n.hcCoverageQ13,
                questionEn: L10n.hcCoverageQ13_en,
                answer: L10n.hcCoverageA13,
                topicType: .coverage
            )
        case .q14:
            return .init(
                question: L10n.hcCoverageQ14,
                questionEn: L10n.hcCoverageQ14_en,
                answer: L10n.hcCoverageA14,
                topicType: .coverage
            )
        case .q15:
            return .init(
                question: L10n.hcCoverageQ15,
                questionEn: L10n.hcCoverageQ15_en,
                answer: L10n.hcCoverageA15,
                topicType: .coverage
            )
        case .q17:
            return .init(
                question: L10n.hcCoverageQ17,
                questionEn: L10n.hcCoverageQ17_en,
                answer: L10n.hcCoverageA17,
                topicType: .coverage
            )
        case .q18:
            return .init(
                question: L10n.hcCoverageQ18,
                questionEn: L10n.hcCoverageQ18_en,
                answer: L10n.hcCoverageA18,
                topicType: .coverage
            )
        case .q19:
            return .init(
                question: L10n.hcCoverageQ19,
                questionEn: L10n.hcCoverageQ19_en,
                answer: L10n.hcCoverageA19,
                topicType: .coverage
            )
        case .q20:
            return .init(
                question: L10n.hcCoverageQ20,
                questionEn: L10n.hcCoverageQ20_en,
                answer: L10n.hcCoverageA20,
                topicType: .coverage
            )
        case .q21:
            return .init(
                question: L10n.hcCoverageQ21,
                questionEn: L10n.hcCoverageQ21_en,
                answer: L10n.hcCoverageA21,
                topicType: .coverage
            )
        case .q22:
            return .init(
                question: L10n.hcCoverageQ22,
                questionEn: L10n.hcCoverageQ22_en,
                answer: L10n.hcCoverageA22,
                topicType: .coverage
            )
        }
    }
}

extension CoverageQuestions: QuestionProtocol {
    static func all() -> [CoverageQuestions] {
        return CoverageQuestions.allCases
    }

    static func common() -> [CoverageQuestions] {
        return [.q1, .q2, .q3]
    }

    static func others() -> [CoverageQuestions] {
        let allQuestions = all()
        let commmonQuestions = common()
        return allQuestions.filter({ !commmonQuestions.contains($0) })
    }
    func asQuestion() -> Question {
        return question
    }
}

enum InsuranceQuestions: CaseIterable {
    case q1
    case q2
    case q3
    case q4
    case q5
    case q6
    case q7
    case q8
    case q9
    case q10
    var question: Question {
        switch self {
        case .q1:
            return .init(
                question: L10n.hcInsuranceQ01,
                questionEn: L10n.hcInsuranceQ01_en,
                answer: L10n.hcInsuranceA01,
                topicType: .myInsurance
            )
        case .q2:
            return .init(
                question: L10n.hcInsuranceQ02,
                questionEn: L10n.hcInsuranceQ02_en,
                answer: L10n.hcInsuranceA02,
                topicType: .myInsurance
            )
        case .q3:
            return .init(
                question: L10n.hcInsuranceQ03,
                questionEn: L10n.hcInsuranceQ03_en,
                answer: L10n.hcInsuranceA03,
                topicType: .myInsurance
            )
        case .q4:
            return .init(
                question: L10n.hcInsuranceQ04,
                questionEn: L10n.hcInsuranceQ04_en,
                answer: L10n.hcInsuranceA04,
                topicType: .myInsurance
            )
        case .q5:
            return .init(
                question: L10n.hcInsuranceQ05,
                questionEn: L10n.hcInsuranceQ05_en,
                answer: L10n.hcInsuranceA05,
                topicType: .myInsurance
            )
        case .q6:
            return .init(
                question: L10n.hcInsuranceQ06,
                questionEn: L10n.hcInsuranceQ06_en,
                answer: L10n.hcInsuranceA06,
                topicType: .myInsurance
            )
        case .q7:
            return .init(
                question: L10n.hcInsuranceQ07,
                questionEn: L10n.hcInsuranceQ07_en,
                answer: L10n.hcInsuranceA07,
                topicType: .myInsurance
            )
        case .q8:
            return .init(
                question: L10n.hcInsuranceQ08,
                questionEn: L10n.hcInsuranceQ08_en,
                answer: L10n.hcInsuranceA08,
                topicType: .myInsurance
            )
        case .q9:
            return .init(
                question: L10n.hcInsuranceQ09,
                questionEn: L10n.hcInsuranceQ09_en,
                answer: L10n.hcInsuranceA09,
                topicType: .myInsurance
            )
        case .q10:
            return .init(
                question: L10n.hcInsuranceQ10,
                questionEn: L10n.hcInsuranceQ10_en,
                answer: L10n.hcInsuranceA10,
                topicType: .myInsurance
            )
        }
    }
}

extension InsuranceQuestions: QuestionProtocol {
    static func all() -> [InsuranceQuestions] {
        return InsuranceQuestions.allCases
    }

    static func common() -> [InsuranceQuestions] {
        return [.q1, .q2, .q3]
    }

    static func others() -> [InsuranceQuestions] {
        let allQuestions = all()
        let commmonQuestions = common()
        return allQuestions.filter({ !commmonQuestions.contains($0) })
    }
    func asQuestion() -> Question {
        return question
    }
}

enum OtherQuestions: CaseIterable {
    case q1
    case q2
    case q3
    case q4
    var question: Question {
        switch self {
        case .q1:
            return .init(
                question: L10n.hcOtherQ01,
                questionEn: L10n.hcOtherQ01_en,
                answer: L10n.hcOtherA01,
                topicType: nil
            )
        case .q2:
            return .init(
                question: L10n.hcOtherQ02,
                questionEn: L10n.hcOtherQ02_en,
                answer: L10n.hcOtherA02,
                topicType: nil
            )
        case .q3:
            return .init(
                question: L10n.hcOtherQ03,
                questionEn: L10n.hcOtherQ03_en,
                answer: L10n.hcOtherA03,
                topicType: nil
            )
        case .q4:
            return .init(
                question: L10n.hcOtherQ04,
                questionEn: L10n.hcOtherQ04_en,
                answer: L10n.hcOtherA04,
                topicType: nil
            )
        }
    }
}

extension OtherQuestions: QuestionProtocol {
    static func all() -> [OtherQuestions] {
        return OtherQuestions.allCases
    }

    static func common() -> [OtherQuestions] {
        return [.q1, .q2, .q3]
    }

    static func others() -> [OtherQuestions] {
        let allQuestions = all()
        let commmonQuestions = common()
        return allQuestions.filter({ !commmonQuestions.contains($0) })
    }
    func asQuestion() -> Question {
        return question
    }
}

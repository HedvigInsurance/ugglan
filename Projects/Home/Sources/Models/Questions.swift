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
    case paymentsQuestion1
    case paymentsQuestion2
    case paymentsQuestion3
    case paymentsQuestion4
    case paymentsQuestion5
    case paymentsQuestion6
    case paymentsQuestion7
    case paymentsQuestion8
    case paymentsQuestion9
    case paymentsQuestion10
    case paymentsQuestion11
    case paymentsQuestion12
    case paymentsQuestion13
    case paymentsQuestion14

    var question: Question {
        switch self {
        case .paymentsQuestion1:
            return .init(
                question: L10n.hcPaymentsQ01,
                questionEn: L10n.hcPaymentsQ01_en,
                answer: L10n.hcPaymentsA01
                    //                topicType: .payments
            )
        case .paymentsQuestion2:
            return .init(
                question: L10n.hcPaymentsQ02,
                questionEn: L10n.hcPaymentsQ02_en,
                answer: L10n.hcPaymentsA02
                    //                topicType: .payments
            )
        case .paymentsQuestion3:
            return .init(
                question: L10n.hcPaymentsQ03,
                questionEn: L10n.hcPaymentsQ03_en,
                answer: L10n.hcPaymentsA03
                    //                topicType: .payments
            )
        case .paymentsQuestion4:
            return .init(
                question: L10n.hcPaymentsQ04,
                questionEn: L10n.hcPaymentsQ04_en,
                answer: L10n.hcPaymentsA04
                    //                topicType: .payments
            )
        case .paymentsQuestion5:
            return .init(
                question: L10n.hcPaymentsQ05,
                questionEn: L10n.hcPaymentsQ05_en,
                answer: L10n.hcPaymentsA05
                    //                topicType: .payments
            )
        case .paymentsQuestion6:
            return .init(
                question: L10n.hcPaymentsQ06,
                questionEn: L10n.hcPaymentsQ06_en,
                answer: L10n.hcPaymentsA06
                    //                topicType: .payments
            )
        case .paymentsQuestion7:
            return .init(
                question: L10n.hcPaymentsQ07,
                questionEn: L10n.hcPaymentsQ07_en,
                answer: L10n.hcPaymentsA07
                    //                topicType: .payments
            )
        case .paymentsQuestion8:
            return .init(
                question: L10n.hcPaymentsQ08,
                questionEn: L10n.hcPaymentsQ08_en,
                answer: L10n.hcPaymentsA08
                    //                topicType: .payments
            )
        case .paymentsQuestion9:
            return .init(
                question: L10n.hcPaymentsQ09,
                questionEn: L10n.hcPaymentsQ09_en,
                answer: L10n.hcPaymentsA09
                    //                topicType: .payments
            )
        case .paymentsQuestion10:
            return .init(
                question: L10n.hcPaymentsQ10,
                questionEn: L10n.hcPaymentsQ10_en,
                answer: L10n.hcPaymentsA10
                    //                topicType: .payments
            )
        case .paymentsQuestion11:
            return .init(
                question: L10n.hcPaymentsQ11,
                questionEn: L10n.hcPaymentsQ11_en,
                answer: L10n.hcPaymentsA11
                    //                topicType: .payments
            )
        case .paymentsQuestion12:
            return .init(
                question: L10n.hcPaymentsQ12,
                questionEn: L10n.hcPaymentsQ12_en,
                answer: L10n.hcPaymentsA12
                    //                topicType: .payments
            )
        case .paymentsQuestion13:
            return .init(
                question: L10n.hcPaymentsQ13,
                questionEn: L10n.hcPaymentsQ13_en,
                answer: L10n.hcPaymentsA13
                    //                topicType: .payments
            )
        case .paymentsQuestion14:
            return .init(
                question: L10n.hcPaymentsQ14,
                questionEn: L10n.hcPaymentsQ14_en,
                answer: L10n.hcPaymentsA14
                    //                topicType: .payments
            )
        }
    }
}

extension PaymentsQuestions: QuestionProtocol {
    static func all() -> [PaymentsQuestions] {
        return PaymentsQuestions.allCases
    }

    static func common() -> [PaymentsQuestions] {
        return [.paymentsQuestion1, .paymentsQuestion2, .paymentsQuestion3]
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
    case claimsQuestion1
    case claimsQuestion2
    case claimsQuestion3
    case claimsQuestion4
    case claimsQuestion5
    case claimsQuestion6
    case claimsQuestion7
    case claimsQuestion8
    case claimsQuestion9
    case claimsQuestion10
    case claimsQuestion11
    case claimsQuestion12

    var question: Question {
        switch self {
        case .claimsQuestion1:
            return .init(
                question: L10n.hcClaimsQ01,
                questionEn: L10n.hcClaimsQ01_en,
                answer: L10n.hcClaimsA01
                    //                topicType: .claims
            )
        case .claimsQuestion2:
            return .init(
                question: L10n.hcClaimsQ02,
                questionEn: L10n.hcClaimsQ02_en,
                answer: L10n.hcClaimsA02
                    //                topicType: .claims
            )
        case .claimsQuestion3:
            return .init(
                question: L10n.hcClaimsQ03,
                questionEn: L10n.hcClaimsQ03_en,
                answer: L10n.hcClaimsA03
                    //                topicType: .claims
            )
        case .claimsQuestion4:
            return .init(
                question: L10n.hcClaimsQ04,
                questionEn: L10n.hcClaimsQ04_en,
                answer: L10n.hcClaimsA04
                    //                topicType: .claims
            )

        case .claimsQuestion5:
            return .init(
                question: L10n.hcClaimsQ05,
                questionEn: L10n.hcClaimsQ05_en,
                answer: L10n.hcClaimsA05
                    //                topicType: .claims
            )
        case .claimsQuestion6:
            return .init(
                question: L10n.hcClaimsQ06,
                questionEn: L10n.hcClaimsQ06_en,
                answer: L10n.hcClaimsA06
                    //                topicType: .claims
            )
        case .claimsQuestion7:
            return .init(
                question: L10n.hcClaimsQ07,
                questionEn: L10n.hcClaimsQ07_en,
                answer: L10n.hcClaimsA07
                    //                topicType: .claims
            )
        case .claimsQuestion8:
            return .init(
                question: L10n.hcClaimsQ08,
                questionEn: L10n.hcClaimsQ08_en,
                answer: L10n.hcClaimsA08
                    //                topicType: .claims
            )
        case .claimsQuestion9:
            return .init(
                question: L10n.hcClaimsQ09,
                questionEn: L10n.hcClaimsQ09_en,
                answer: L10n.hcClaimsA09
                    //                topicType: .claims
            )
        case .claimsQuestion10:
            return .init(
                question: L10n.hcClaimsQ10,
                questionEn: L10n.hcClaimsQ10_en,
                answer: L10n.hcClaimsA10
                    //                topicType: .claims
            )
        case .claimsQuestion11:
            return .init(
                question: L10n.hcClaimsQ11,
                questionEn: L10n.hcClaimsQ11_en,
                answer: L10n.hcClaimsA11
                    //                topicType: .claims
            )
        case .claimsQuestion12:
            return .init(
                question: L10n.hcClaimsQ12,
                questionEn: L10n.hcClaimsQ12_en,
                answer: L10n.hcClaimsA12
                    //                topicType: .claims
            )
        }
    }
}

extension ClaimsQuestions: QuestionProtocol {
    static func all() -> [ClaimsQuestions] {
        return ClaimsQuestions.allCases
    }

    static func common() -> [ClaimsQuestions] {
        return [.claimsQuestion1, .claimsQuestion2, .claimsQuestion3]
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
    case coverageQuestion1
    case coverageQuestion2
    case coverageQuestion3
    case coverageQuestion4
    case coverageQuestion5
    case coverageQuestion6
    case coverageQuestion7
    case coverageQuestion8
    case coverageQuestion9
    case coverageQuestion10
    case coverageQuestion11
    case coverageQuestion12
    case coverageQuestion13
    case coverageQuestion14
    case coverageQuestion15
    case coverageQuestion17
    case coverageQuestion18
    case coverageQuestion19
    case coverageQuestion20
    case coverageQuestion21
    case coverageQuestion22
    var question: Question {
        switch self {
        case .coverageQuestion1:
            return .init(
                question: L10n.hcCoverageQ01,
                questionEn: L10n.hcCoverageQ01_en,
                answer: L10n.hcCoverageA01
                    //                topicType: .coverage
            )

        case .coverageQuestion2:
            return .init(
                question: L10n.hcCoverageQ02,
                questionEn: L10n.hcCoverageQ02_en,
                answer: L10n.hcCoverageA02
                    //                topicType: .coverage
            )
        case .coverageQuestion3:
            return .init(
                question: L10n.hcCoverageQ03,
                questionEn: L10n.hcCoverageQ03_en,
                answer: L10n.hcCoverageA03
                    //                topicType: .coverage
            )
        case .coverageQuestion4:
            return .init(
                question: L10n.hcCoverageQ04,
                questionEn: L10n.hcCoverageQ04_en,
                answer: L10n.hcCoverageA04
                    //                topicType: .coverage
            )
        case .coverageQuestion5:
            return .init(
                question: L10n.hcCoverageQ05,
                questionEn: L10n.hcCoverageQ05_en,
                answer: L10n.hcCoverageA05
                    //                topicType: .coverage
            )
        case .coverageQuestion6:
            return .init(
                question: L10n.hcCoverageQ06,
                questionEn: L10n.hcCoverageQ06_en,
                answer: L10n.hcCoverageA06
                    //                topicType: .coverage
            )
        case .coverageQuestion7:
            return .init(
                question: L10n.hcCoverageQ07,
                questionEn: L10n.hcCoverageQ07_en,
                answer: L10n.hcCoverageA07
                    //                topicType: .coverage
            )
        case .coverageQuestion8:
            return .init(
                question: L10n.hcCoverageQ08,
                questionEn: L10n.hcCoverageQ08_en,
                answer: L10n.hcCoverageA08
                    //                topicType: .coverage
            )
        case .coverageQuestion9:
            return .init(
                question: L10n.hcCoverageQ09,
                questionEn: L10n.hcCoverageQ09_en,
                answer: L10n.hcCoverageA09
                    //                topicType: .coverage
            )
        case .coverageQuestion10:
            return .init(
                question: L10n.hcCoverageQ10,
                questionEn: L10n.hcCoverageQ10_en,
                answer: L10n.hcCoverageA10
                    //                topicType: .coverage
            )
        case .coverageQuestion11:
            return .init(
                question: L10n.hcCoverageQ11,
                questionEn: L10n.hcCoverageQ11_en,
                answer: L10n.hcCoverageA11
                    //                topicType: .coverage
            )
        case .coverageQuestion12:
            return .init(
                question: L10n.hcCoverageQ12,
                questionEn: L10n.hcCoverageQ12_en,
                answer: L10n.hcCoverageA12
                    //                topicType: .coverage
            )
        case .coverageQuestion13:
            return .init(
                question: L10n.hcCoverageQ13,
                questionEn: L10n.hcCoverageQ13_en,
                answer: L10n.hcCoverageA13
                    //                topicType: .coverage
            )
        case .coverageQuestion14:
            return .init(
                question: L10n.hcCoverageQ14,
                questionEn: L10n.hcCoverageQ14_en,
                answer: L10n.hcCoverageA14
                    //                topicType: .coverage
            )
        case .coverageQuestion15:
            return .init(
                question: L10n.hcCoverageQ15,
                questionEn: L10n.hcCoverageQ15_en,
                answer: L10n.hcCoverageA15
                    //                topicType: .coverage
            )
        case .coverageQuestion17:
            return .init(
                question: L10n.hcCoverageQ17,
                questionEn: L10n.hcCoverageQ17_en,
                answer: L10n.hcCoverageA17
                    //                topicType: .coverage
            )
        case .coverageQuestion18:
            return .init(
                question: L10n.hcCoverageQ18,
                questionEn: L10n.hcCoverageQ18_en,
                answer: L10n.hcCoverageA18
                    //                topicType: .coverage
            )
        case .coverageQuestion19:
            return .init(
                question: L10n.hcCoverageQ19,
                questionEn: L10n.hcCoverageQ19_en,
                answer: L10n.hcCoverageA19
                    //                topicType: .coverage
            )
        case .coverageQuestion20:
            return .init(
                question: L10n.hcCoverageQ20,
                questionEn: L10n.hcCoverageQ20_en,
                answer: L10n.hcCoverageA20
                    //                topicType: .coverage
            )
        case .coverageQuestion21:
            return .init(
                question: L10n.hcCoverageQ21,
                questionEn: L10n.hcCoverageQ21_en,
                answer: L10n.hcCoverageA21
                    //                topicType: .coverage
            )
        case .coverageQuestion22:
            return .init(
                question: L10n.hcCoverageQ22,
                questionEn: L10n.hcCoverageQ22_en,
                answer: L10n.hcCoverageA22
                    //                topicType: .coverage
            )
        }
    }
}

extension CoverageQuestions: QuestionProtocol {
    static func all() -> [CoverageQuestions] {
        return CoverageQuestions.allCases
    }

    static func common() -> [CoverageQuestions] {
        return [.coverageQuestion1, .coverageQuestion2, .coverageQuestion3]
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
    case insuranceQuestion1
    case insuranceQuestion2
    case insuranceQuestion3
    case insuranceQuestion4
    case insuranceQuestion5
    case insuranceQuestion6
    case insuranceQuestion7
    case insuranceQuestion8
    case insuranceQuestion9
    case insuranceQuestion10
    var question: Question {
        switch self {
        case .insuranceQuestion1:
            return .init(
                question: L10n.hcInsuranceQ01,
                questionEn: L10n.hcInsuranceQ01_en,
                answer: L10n.hcInsuranceA01
                    //                topicType: .myInsurance
            )
        case .insuranceQuestion2:
            return .init(
                question: L10n.hcInsuranceQ02,
                questionEn: L10n.hcInsuranceQ02_en,
                answer: L10n.hcInsuranceA02
                    //                topicType: .myInsurance
            )
        case .insuranceQuestion3:
            return .init(
                question: L10n.hcInsuranceQ03,
                questionEn: L10n.hcInsuranceQ03_en,
                answer: L10n.hcInsuranceA03
                    //                topicType: .myInsurance
            )
        case .insuranceQuestion4:
            return .init(
                question: L10n.hcInsuranceQ04,
                questionEn: L10n.hcInsuranceQ04_en,
                answer: L10n.hcInsuranceA04
                    //                topicType: .myInsurance
            )
        case .insuranceQuestion5:
            return .init(
                question: L10n.hcInsuranceQ05,
                questionEn: L10n.hcInsuranceQ05_en,
                answer: L10n.hcInsuranceA05
                    //                topicType: .myInsurance
            )
        case .insuranceQuestion6:
            return .init(
                question: L10n.hcInsuranceQ06,
                questionEn: L10n.hcInsuranceQ06_en,
                answer: L10n.hcInsuranceA06
                    //                topicType: .myInsurance
            )
        case .insuranceQuestion7:
            return .init(
                question: L10n.hcInsuranceQ07,
                questionEn: L10n.hcInsuranceQ07_en,
                answer: L10n.hcInsuranceA07
                    //                topicType: .myInsurance
            )
        case .insuranceQuestion8:
            return .init(
                question: L10n.hcInsuranceQ08,
                questionEn: L10n.hcInsuranceQ08_en,
                answer: L10n.hcInsuranceA08
                    //                topicType: .myInsurance
            )
        case .insuranceQuestion9:
            return .init(
                question: L10n.hcInsuranceQ09,
                questionEn: L10n.hcInsuranceQ09_en,
                answer: L10n.hcInsuranceA09
                    //                topicType: .myInsurance
            )
        case .insuranceQuestion10:
            return .init(
                question: L10n.hcInsuranceQ10,
                questionEn: L10n.hcInsuranceQ10_en,
                answer: L10n.hcInsuranceA10
                    //                topicType: .myInsurance
            )
        }
    }
}

extension InsuranceQuestions: QuestionProtocol {
    static func all() -> [InsuranceQuestions] {
        return InsuranceQuestions.allCases
    }

    static func common() -> [InsuranceQuestions] {
        return [.insuranceQuestion1, .insuranceQuestion2, .insuranceQuestion3]
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
    case otherQuestion1
    case otherQuestion2
    case otherQuestion3
    case otherQuestion4
    var question: Question {
        switch self {
        case .otherQuestion1:
            return .init(
                question: L10n.hcOtherQ01,
                questionEn: L10n.hcOtherQ01_en,
                answer: L10n.hcOtherA01
                    //                topicType: nil
            )
        case .otherQuestion2:
            return .init(
                question: L10n.hcOtherQ02,
                questionEn: L10n.hcOtherQ02_en,
                answer: L10n.hcOtherA02
                    //                topicType: nil
            )
        case .otherQuestion3:
            return .init(
                question: L10n.hcOtherQ03,
                questionEn: L10n.hcOtherQ03_en,
                answer: L10n.hcOtherA03
                    //                topicType: nil
            )
        case .otherQuestion4:
            return .init(
                question: L10n.hcOtherQ04,
                questionEn: L10n.hcOtherQ04_en,
                answer: L10n.hcOtherA04
                    //                topicType: nil
            )
        }
    }
}

extension OtherQuestions: QuestionProtocol {
    static func all() -> [OtherQuestions] {
        return OtherQuestions.allCases
    }

    static func common() -> [OtherQuestions] {
        return [.otherQuestion1, .otherQuestion2, .otherQuestion3]
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

import Foundation
import hCore

enum PaymentsQuestions {
    static var q1: Question {
        return .init(question: L10n.hcPaymentsQ01, answer: L10n.hcPaymentsA01, topicType: .payments)
    }
    static var q2: Question {
        return .init(question: L10n.hcPaymentsQ02, answer: L10n.hcPaymentsA02, topicType: .payments)
    }
    static var q3: Question {
        return .init(question: L10n.hcPaymentsQ03, answer: L10n.hcPaymentsA03, topicType: .payments)
    }
    static var q4: Question {
        return .init(question: L10n.hcPaymentsQ04, answer: L10n.hcPaymentsA04, topicType: .payments)
    }
    static var q5: Question {
        return .init(question: L10n.hcPaymentsQ05, answer: L10n.hcPaymentsA05, topicType: .payments)
    }
    static var q6: Question {
        return .init(question: L10n.hcPaymentsQ06, answer: L10n.hcPaymentsA06, topicType: .payments)
    }
    static var q7: Question {
        return .init(question: L10n.hcPaymentsQ07, answer: L10n.hcPaymentsA07, topicType: .payments)
    }
    static var q8: Question {
        return .init(question: L10n.hcPaymentsQ08, answer: L10n.hcPaymentsA08, topicType: .payments)
    }
    static var q9: Question {
        return .init(question: L10n.hcPaymentsQ09, answer: L10n.hcPaymentsA09, topicType: .payments)
    }
    static var q10: Question {
        return .init(question: L10n.hcPaymentsQ10, answer: L10n.hcPaymentsA10, topicType: .payments)
    }
    static var q11: Question {
        return .init(question: L10n.hcPaymentsQ11, answer: L10n.hcPaymentsA11, topicType: .payments)
    }
    static var q12: Question {
        return .init(question: L10n.hcPaymentsQ12, answer: L10n.hcPaymentsA12, topicType: .payments)
    }
    static var q13: Question {
        return .init(question: L10n.hcPaymentsQ13, answer: L10n.hcPaymentsA13, topicType: .payments)
    }
    static var q14: Question {
        return .init(question: L10n.hcPaymentsQ14, answer: L10n.hcPaymentsA14, topicType: .payments)
    }
}

enum ClaimsQuestions {
    static var q1: Question { return .init(question: L10n.hcClaimsQ01, answer: L10n.hcClaimsA01, topicType: .claims) }
    static var q2: Question { return .init(question: L10n.hcClaimsQ02, answer: L10n.hcClaimsA02, topicType: .claims) }
    static var q3: Question { return .init(question: L10n.hcClaimsQ03, answer: L10n.hcClaimsA03, topicType: .claims) }
    static var q4: Question { return .init(question: L10n.hcClaimsQ04, answer: L10n.hcClaimsA04, topicType: .claims) }
    static var q5: Question { return .init(question: L10n.hcClaimsQ05, answer: L10n.hcClaimsA05, topicType: .claims) }
    static var q6: Question { return .init(question: L10n.hcClaimsQ06, answer: L10n.hcClaimsA06, topicType: .claims) }
    static var q7: Question { return .init(question: L10n.hcClaimsQ07, answer: L10n.hcClaimsA07, topicType: .claims) }
    static var q8: Question { return .init(question: L10n.hcClaimsQ08, answer: L10n.hcClaimsA08, topicType: .claims) }
    static var q9: Question { return .init(question: L10n.hcClaimsQ09, answer: L10n.hcClaimsA09, topicType: .claims) }
    static var q10: Question { return .init(question: L10n.hcClaimsQ10, answer: L10n.hcClaimsA10, topicType: .claims) }
    static var q11: Question { return .init(question: L10n.hcClaimsQ11, answer: L10n.hcClaimsA11, topicType: .claims) }
    static var q12: Question { return .init(question: L10n.hcClaimsQ12, answer: L10n.hcClaimsA12, topicType: .claims) }
}

enum CoverageQuestions {
    static var q1: Question {
        return .init(question: L10n.hcCoverageQ01, answer: L10n.hcCoverageA01, topicType: .coverage)
    }
    static var q2: Question {
        return .init(question: L10n.hcCoverageQ02, answer: L10n.hcCoverageA02, topicType: .coverage)
    }
    static var q3: Question {
        return .init(question: L10n.hcCoverageQ03, answer: L10n.hcCoverageA03, topicType: .coverage)
    }
    static var q4: Question {
        return .init(question: L10n.hcCoverageQ04, answer: L10n.hcCoverageA04, topicType: .coverage)
    }
    static var q5: Question {
        return .init(question: L10n.hcCoverageQ05, answer: L10n.hcCoverageA05, topicType: .coverage)
    }
    static var q6: Question {
        return .init(question: L10n.hcCoverageQ06, answer: L10n.hcCoverageA06, topicType: .coverage)
    }
    static var q7: Question {
        return .init(question: L10n.hcCoverageQ07, answer: L10n.hcCoverageA07, topicType: .coverage)
    }
    static var q8: Question {
        return .init(question: L10n.hcCoverageQ08, answer: L10n.hcCoverageA08, topicType: .coverage)
    }
    static var q9: Question {
        return .init(question: L10n.hcCoverageQ09, answer: L10n.hcCoverageA09(0), topicType: .coverage)
    }
    static var q10: Question {
        return .init(question: L10n.hcCoverageQ10, answer: L10n.hcCoverageA10, topicType: .coverage)
    }
    static var q11: Question {
        return .init(question: L10n.hcCoverageQ11, answer: L10n.hcCoverageA11, topicType: .coverage)
    }
    static var q12: Question {
        return .init(question: L10n.hcCoverageQ12, answer: L10n.hcCoverageA12(0), topicType: .coverage)
    }
    static var q13: Question {
        return .init(question: L10n.hcCoverageQ13, answer: L10n.hcCoverageA13, topicType: .coverage)
    }
    static var q14: Question {
        return .init(question: L10n.hcCoverageQ14, answer: L10n.hcCoverageA14, topicType: .coverage)
    }
    static var q15: Question {
        return .init(question: L10n.hcCoverageQ15, answer: L10n.hcCoverageA15, topicType: .coverage)
    }
    static var q16: Question {
        return .init(question: L10n.hcCoverageQ16, answer: L10n.hcCoverageA16, topicType: .coverage)
    }
    static var q17: Question {
        return .init(question: L10n.hcCoverageQ17, answer: L10n.hcCoverageA17, topicType: .coverage)
    }
    static var q18: Question {
        return .init(question: L10n.hcCoverageQ18, answer: L10n.hcCoverageA18, topicType: .coverage)
    }
    static var q19: Question {
        return .init(question: L10n.hcCoverageQ19, answer: L10n.hcCoverageA19, topicType: .coverage)
    }
    static var q20: Question {
        return .init(question: L10n.hcCoverageQ20, answer: L10n.hcCoverageA20, topicType: .coverage)
    }
    static var q21: Question {
        return .init(question: L10n.hcCoverageQ21, answer: L10n.hcCoverageA21, topicType: .coverage)
    }
    static var q22: Question {
        return .init(question: L10n.hcCoverageQ22, answer: L10n.hcCoverageA22, topicType: .coverage)
    }
}

enum InsuranceQuestions {
    static var q1: Question {
        return .init(question: L10n.hcInsuranceQ01, answer: L10n.hcInsuranceA01, topicType: .myInsurance)
    }
    static var q2: Question {
        return .init(question: L10n.hcInsuranceQ02, answer: L10n.hcInsuranceA02, topicType: .myInsurance)
    }
    static var q3: Question {
        return .init(question: L10n.hcInsuranceQ03, answer: L10n.hcInsuranceA03, topicType: .myInsurance)
    }
    static var q4: Question {
        return .init(question: L10n.hcInsuranceQ04, answer: L10n.hcInsuranceA04, topicType: .myInsurance)
    }
    static var q5: Question {
        return .init(question: L10n.hcInsuranceQ05, answer: L10n.hcInsuranceA05, topicType: .myInsurance)
    }
    static var q6: Question {
        return .init(question: L10n.hcInsuranceQ06, answer: L10n.hcInsuranceA06, topicType: .myInsurance)
    }
    static var q7: Question {
        return .init(question: L10n.hcInsuranceQ07, answer: L10n.hcInsuranceA07, topicType: .myInsurance)
    }
    static var q8: Question {
        return .init(question: L10n.hcInsuranceQ08, answer: L10n.hcInsuranceA08, topicType: .myInsurance)
    }
    static var q9: Question {
        return .init(question: L10n.hcInsuranceQ09, answer: L10n.hcInsuranceA09, topicType: .myInsurance)
    }
    static var q10: Question {
        return .init(question: L10n.hcInsuranceQ10, answer: L10n.hcInsuranceA10, topicType: .myInsurance)
    }
}
enum OtherQuestions {
    static var q1: Question {
        return .init(question: L10n.hcOtherQ01, answer: L10n.hcOtherA01, topicType: nil)
    }
    static var q2: Question {
        return .init(question: L10n.hcOtherQ02, answer: L10n.hcOtherA02, topicType: nil)
    }
    static var q3: Question {
        return .init(question: L10n.hcOtherQ03, answer: L10n.hcOtherA03, topicType: nil)
    }
    static var q4: Question {
        return .init(question: L10n.hcOtherQ04, answer: L10n.hcOtherA04, topicType: nil)
    }
}

import Foundation

public class HomeClientDemo: HomeClient {
    public init() {}

    public func getImportantMessages() async throws -> [ImportantMessage] {
        []
    }

    public func getMemberState() async throws -> MemberState {
        .init(
            memberInfo: .init(id: "id", isContactInfoUpdateNeeded: false),
            contracts: [],
            contractState: MemberContractState.active,
            futureState: FutureStatus.none
        )
    }

    public func getQuickActions() async throws -> [QuickAction] {
        []
    }

    public func getMessagesState() async throws -> MessageState {
        .init(hasNewMessages: false, hasSentOrRecievedAtLeastOneMessage: true, lastMessageTimeStamp: nil)
    }

    public func getNumberOfClaims() async throws -> Int {
        0
    }

    public func getFAQ() async throws -> HelpCenterFAQModel {
        let question1 = FAQModel(
            id: "id1",
            question: "How do I add more insurances?",
            answer:
                "You can easily add more insurance policies at hedvig.com. As soon as you sign a new policy with Hedvig, it will appear here in the app. Read more about our insurances [here](https://www.hedvig.com/se/forsakringar).\n\nDo you want to sign by phone? Call us on +46 10-45 99 200 on weekdays between 9-16."
        )
        let question2 = FAQModel(
            id: "id2",
            question: "How do I delete my account?",
            answer:
                "As an insurance company, Hedvig is obliged to keep the insurance contract and related information for as long as it is possible to make a claim for insurance compensation. This period may vary depending on the type of insurance but is at least 10 years after the expiry of the insurance based on limitation periods.\n\nThese rules affect the possibility to delete an account, as described below.\n\nIf you have an active policy with us, we cannot delete your account. If you want to cancel your insurance, you can do so [here](https://hedvig.page.link/insurances), then select the policy you want to cancel and click on Cancel insurance.\n\nIf you have an open claim, we recommend keeping your account active until your claim is closed. To track of the status of your claim and get messages from our service team, please keep the Hedvig app on your phone.\n\nIf you have cancelled your insurance with Hedvig, we are obliged to save your insurance contract and related information (e.g. registered claims) for at least 10 years after the cancellation of the insurance."
        )

        let topic1 = FaqTopic(
            id: "topic1",
            title: "Payments",
            commonQuestions: [
                question1
            ],
            allQuestions: [
                question2
            ]
        )
        return .init(
            topics: [
                topic1
            ],
            commonQuestions: [
                question1,
                question2,
            ]
        )
    }
}
